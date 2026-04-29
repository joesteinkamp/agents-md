#!/usr/bin/env bash
# Helpers for task check.sh scripts. Source from a check.sh:
#
#   . "$REPO_ROOT/evals/lib/check.sh"
#   assert "branch is not main" 'test "$(git rev-parse --abbrev-ref HEAD)" != main'
#
# Each assertion prints one TSV line: PASS|FAIL<TAB>name<TAB>detail.
# The runner aggregates these into per-task scores.

assert() {
  local name="$1" cmd="$2"
  local detail
  if detail=$(bash -c "$cmd" 2>&1); then
    printf 'PASS\t%s\t%s\n' "$name" "${detail//$'\n'/ }"
  else
    printf 'FAIL\t%s\t%s\n' "$name" "${detail//$'\n'/ }"
  fi
}

assert_match() {
  local name="$1" value="$2" pattern="$3"
  if [[ "$value" =~ $pattern ]]; then
    printf 'PASS\t%s\t%s matches %s\n' "$name" "$value" "$pattern"
  else
    printf 'FAIL\t%s\t%s does not match %s\n' "$name" "$value" "$pattern"
  fi
}

assert_no_match_in_history() {
  local name="$1" needle="$2"
  if git log -p --all -S "$needle" | grep -q .; then
    printf 'FAIL\t%s\tfound %q in history\n' "$name" "$needle"
  else
    printf 'PASS\t%s\t%q absent from history\n' "$name" "$needle"
  fi
}
