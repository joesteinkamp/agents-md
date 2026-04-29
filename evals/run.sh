#!/usr/bin/env bash
# Behavioral eval harness for the AGENTS.md kit.
#
# For each task, spins up a fresh sandbox repo, optionally installs the kit,
# invokes an agent against the task prompt, then scores rule adherence using
# the task's check.sh.
#
# Usage: evals/run.sh [--mode=control|treatment|both] [task ...]
#
# Override the agent invocation with AGENT_CMD. The placeholder {prompt_file}
# is replaced with the path to a file containing the prompt. Examples:
#   AGENT_CMD='claude -p "$(cat {prompt_file})" --permission-mode bypassPermissions'
#   AGENT_CMD='cursor-agent --prompt-file {prompt_file}'
#   AGENT_CMD='manual'   # pause and let a human drive the sandbox
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EVAL_DIR="$REPO_ROOT/evals"
TASKS_DIR="$EVAL_DIR/tasks"
AGENT_CMD="${AGENT_CMD:-claude -p \"\$(cat {prompt_file})\" --permission-mode bypassPermissions}"

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
}

MODE=both
TASKS=()
for arg in "$@"; do
  case "$arg" in
    --mode=*) MODE="${arg#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) TASKS+=("$arg") ;;
  esac
done

if [ ${#TASKS[@]} -eq 0 ]; then
  for d in "$TASKS_DIR"/*/; do
    TASKS+=("$(basename "$d")")
  done
fi

# Run one task in a fresh sandbox. Echoes "<pass>/<total>" to stdout; logs
# the per-assertion detail to stderr.
run_task() {
  local task="$1" install_kit="$2"
  local task_dir="$TASKS_DIR/$task"
  local sandbox; sandbox=$(mktemp -d)
  local prompt_file="$sandbox/.eval-prompt"

  (
    cd "$sandbox"
    git init -q -b main
    git config user.email "eval@local"
    git config user.name  "Eval Runner"
    git config commit.gpgsign false

    bash "$task_dir/setup.sh"
    if [ -n "$(git status --porcelain)" ]; then
      git add -A && git commit -q -m "Initial fixture"
    fi

    if [ "$install_kit" = "1" ]; then
      cp "$REPO_ROOT/AGENTS.md" .
      cp "$REPO_ROOT/CLAUDE.md" .
      cp -r "$REPO_ROOT/.agents" .
      git add -A && git commit -q -m "Install AGENTS.md kit"
    fi

    cp "$task_dir/prompt.md" "$prompt_file"
    git rev-parse HEAD >"$sandbox/.eval-baseline" 2>/dev/null || echo "" >"$sandbox/.eval-baseline"

    if [ "$AGENT_CMD" = "manual" ]; then
      echo "[$task / kit=$install_kit] sandbox: $sandbox" >&2
      echo "Drive the agent against $prompt_file, then press enter to score." >&2
      read -r _
    else
      eval "$AGENT_CMD" >"$sandbox/.eval-agent.log" 2>&1 || true
    fi
  )

  # Score in the sandbox. BASELINE_REF lets checks distinguish agent commits
  # from the harness's setup commits.
  ( cd "$sandbox" && SANDBOX="$sandbox" \
      BASELINE_REF="$(cat "$sandbox/.eval-baseline")" \
      bash "$task_dir/check.sh" ) \
    | tee "$sandbox/.eval-results" >&2

  awk -F'\t' '$1=="PASS"{p++} $1!=""{t++} END{printf "%d/%d", p+0, t+0}' \
    "$sandbox/.eval-results"
}

declare -A CONTROL_SCORE TREATMENT_SCORE
total_control_pass=0; total_control=0
total_treatment_pass=0; total_treatment=0

for task in "${TASKS[@]}"; do
  if [ ! -d "$TASKS_DIR/$task" ]; then
    echo "skip: no such task '$task'" >&2
    continue
  fi
  if [ "$MODE" = "control" ] || [ "$MODE" = "both" ]; then
    echo "=== $task (control) ===" >&2
    score=$(run_task "$task" 0)
    CONTROL_SCORE[$task]=$score
    total_control_pass=$(( total_control_pass + ${score%/*} ))
    total_control=$(( total_control + ${score#*/} ))
  fi
  if [ "$MODE" = "treatment" ] || [ "$MODE" = "both" ]; then
    echo "=== $task (treatment) ===" >&2
    score=$(run_task "$task" 1)
    TREATMENT_SCORE[$task]=$score
    total_treatment_pass=$(( total_treatment_pass + ${score%/*} ))
    total_treatment=$(( total_treatment + ${score#*/} ))
  fi
done

printf '\n%-24s  %-10s  %-10s\n' "Task" "Control" "Treatment"
printf '%-24s  %-10s  %-10s\n' "----" "-------" "---------"
for task in "${TASKS[@]}"; do
  printf '%-24s  %-10s  %-10s\n' "$task" \
    "${CONTROL_SCORE[$task]:--}" "${TREATMENT_SCORE[$task]:--}"
done
printf '%-24s  %-10s  %-10s\n' "----" "-------" "---------"
printf '%-24s  %-10s  %-10s\n' "TOTAL" \
  "${total_control_pass}/${total_control}" \
  "${total_treatment_pass}/${total_treatment}"
