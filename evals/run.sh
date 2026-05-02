#!/usr/bin/env bash
# Behavioral eval harness for the AGENTS.md kit.
#
# Iterates (task × format × agent × rep) cells. Each cell:
#   1. Creates a fresh sandbox repo and runs the task's setup.sh.
#   2. Installs context for the format (full kit / flat rules / nothing).
#   3. Records BASELINE_REF, then invokes the agent against prompt.md.
#   4. Runs check.sh to score rule adherence.
#
# Aggregates pass/total by format×agent so you can answer the sharper
# question — does the structured kit do *better* than a flat rule list, not
# just better than no context at all?
#
# Usage:
#   evals/run.sh [--format=<f>[,<f>...]] [--agent=<id>[,<id>...]]
#                [--reps=N] [--out=PATH] [task ...]
#
# Defaults run every task × format × agent once. Built-in agents:
#   mock-instruction-follower — passes when rules are visible (self-test)
#   mock-chaotic              — fails everything (sanity check on the scorer)
#   claude                    — invokes `claude -p` (real run, costs API spend)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EVAL_DIR="$REPO_ROOT/evals"
TASKS_DIR="$EVAL_DIR/tasks"
AGENTS_DIR="$EVAL_DIR/agents"
. "$EVAL_DIR/lib/format.sh"

DEFAULT_FORMATS=(agentsmd flat none)
DEFAULT_AGENTS=(mock-instruction-follower mock-chaotic)

usage() { sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; }

FORMATS=() AGENTS=() TASKS=() REPS=1 OUT=""
for arg in "$@"; do
  case "$arg" in
    --format=*)  IFS=, read -r -a FORMATS <<<"${arg#*=}" ;;
    --agent=*)   IFS=, read -r -a AGENTS  <<<"${arg#*=}" ;;
    --reps=*)    REPS="${arg#*=}" ;;
    --out=*)     OUT="${arg#*=}" ;;
    -h|--help)   usage; exit 0 ;;
    *)           TASKS+=("$arg") ;;
  esac
done

[ ${#FORMATS[@]} -eq 0 ] && FORMATS=("${DEFAULT_FORMATS[@]}")
[ ${#AGENTS[@]}  -eq 0 ] && AGENTS=("${DEFAULT_AGENTS[@]}")
if [ ${#TASKS[@]} -eq 0 ]; then
  for d in "$TASKS_DIR"/*/; do TASKS+=("$(basename "$d")"); done
fi

# JSON-escape a string for embedding in a JSON literal.
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"; s="${s//$'\r'/\\r}"; s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

invoke_agent() {
  local agent_id="$1" prompt_file="$2"
  case "$agent_id" in
    mock-*)
      bash "$AGENTS_DIR/$agent_id.sh" "$prompt_file"
      ;;
    claude)
      claude -p "$(cat "$prompt_file")" --permission-mode bypassPermissions
      ;;
    custom)
      eval "${AGENT_CMD:?AGENT_CMD required for agent=custom}"
      ;;
    *)
      echo "invoke_agent: unknown agent '$agent_id'" >&2; return 1 ;;
  esac
}

# Run one (task, format, agent) cell. Echoes a JSON object on stdout.
run_cell() {
  local task="$1" format="$2" agent_id="$3" rep="$4"
  local task_dir="$TASKS_DIR/$task"
  local sandbox; sandbox=$(mktemp -d)
  local prompt_file="$sandbox/.eval-prompt"
  local results="$sandbox/.eval-results"

  (
    cd "$sandbox"
    git init -q -b main
    git config user.email "eval@local"
    git config user.name  "Eval Runner"
    git config commit.gpgsign false

    bash "$task_dir/setup.sh"
    [ -n "$(git status --porcelain)" ] && git add -A && git commit -q -m "Initial fixture"

    build_format "$format" "$sandbox" "$REPO_ROOT"
    [ -n "$(git status --porcelain)" ] && git add -A && git commit -q -m "Install context: $format"

    cp "$task_dir/prompt.md" "$prompt_file"
    git rev-parse HEAD > "$sandbox/.eval-baseline"

    invoke_agent "$agent_id" "$prompt_file" > "$sandbox/.eval-agent.log" 2>&1 || true
  )

  ( cd "$sandbox" && SANDBOX="$sandbox" \
      BASELINE_REF="$(cat "$sandbox/.eval-baseline")" \
      bash "$task_dir/check.sh" ) > "$results" 2>/dev/null || true

  local passed total assertions_json="" first=1
  passed=$(awk -F'\t' '$1=="PASS"{p++} END{print p+0}' "$results")
  total=$(awk -F'\t' 'NF>=2{t++}    END{print t+0}' "$results")

  while IFS=$'\t' read -r status name detail; do
    [ -z "${status:-}" ] && continue
    [ $first -eq 1 ] && first=0 || assertions_json+=","
    assertions_json+="{\"status\":\"$(json_escape "$status")\",\"name\":\"$(json_escape "$name")\",\"detail\":\"$(json_escape "${detail:-}")\"}"
  done < "$results"

  printf '{"task":"%s","format":"%s","agent":"%s","rep":%d,"passed":%d,"total":%d,"assertions":[%s]}' \
    "$(json_escape "$task")" "$(json_escape "$format")" "$(json_escape "$agent_id")" \
    "$rep" "$passed" "$total" "$assertions_json"

  echo "[$task / $format / $agent_id / rep=$rep] $passed/$total" >&2
  rm -rf "$sandbox"
}

# Drive all cells, collecting JSON.
runs_json=""; first=1
for task in "${TASKS[@]}"; do
  [ -d "$TASKS_DIR/$task" ] || { echo "skip: no such task '$task'" >&2; continue; }
  for format in "${FORMATS[@]}"; do
    for agent in "${AGENTS[@]}"; do
      for rep in $(seq 1 "$REPS"); do
        cell_json=$(run_cell "$task" "$format" "$agent" "$rep")
        [ $first -eq 1 ] && first=0 || runs_json+=","
        runs_json+="$cell_json"
      done
    done
  done
done

started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
report="{\"startedAt\":\"$started_at\",\"runs\":[$runs_json]}"

# Aggregate by (format, agent): mean pass-rate.
echo "" >&2
printf '%-32s' "Task / Agent" >&2
for format in "${FORMATS[@]}"; do printf '  %-12s' "$format" >&2; done
echo "" >&2
for task in "${TASKS[@]}"; do
  for agent in "${AGENTS[@]}"; do
    printf '%-32s' "$task / $agent" >&2
    for format in "${FORMATS[@]}"; do
      sum=$(printf '%s' "$report" | python3 -c "
import json, sys
r = json.loads(sys.stdin.read())['runs']
cells = [c for c in r if c['task']=='$task' and c['format']=='$format' and c['agent']=='$agent']
p = sum(c['passed'] for c in cells); t = sum(c['total'] for c in cells)
print(f'{p}/{t}' if t else '-')
")
      printf '  %-12s' "$sum" >&2
    done
    echo "" >&2
  done
done
echo "" >&2
printf '%-32s' "TOTAL by format" >&2
for format in "${FORMATS[@]}"; do
  sum=$(printf '%s' "$report" | python3 -c "
import json, sys
r = json.loads(sys.stdin.read())['runs']
cells = [c for c in r if c['format']=='$format']
p = sum(c['passed'] for c in cells); t = sum(c['total'] for c in cells)
print(f'{p}/{t}' if t else '-')
")
  printf '  %-12s' "$sum" >&2
done
echo "" >&2

if [ -n "$OUT" ]; then
  mkdir -p "$(dirname "$OUT")"
  printf '%s\n' "$report" | python3 -m json.tool > "$OUT"
  echo "Wrote ${OUT}" >&2
fi
