#!/usr/bin/env bash
# Tiny assertion library for the kit's own shell tests.
# Each test file sources this and uses t_assert / t_assert_eq.
# At end of file: call t_summary; the runner aggregates exit codes.

T_PASS=0
T_FAIL=0
T_NAME="${T_NAME:-$(basename "${BASH_SOURCE[1]:-unknown}")}"

t_assert() {
  local name="$1" cmd="$2"
  if bash -c "$cmd" >/dev/null 2>&1; then
    printf '  PASS  %s\n' "$name"
    T_PASS=$((T_PASS + 1))
  else
    printf '  FAIL  %s\n    cmd: %s\n' "$name" "$cmd"
    T_FAIL=$((T_FAIL + 1))
  fi
}

t_assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    printf '  PASS  %s\n' "$name"
    T_PASS=$((T_PASS + 1))
  else
    printf '  FAIL  %s\n    expected: %q\n    actual:   %q\n' "$name" "$expected" "$actual"
    T_FAIL=$((T_FAIL + 1))
  fi
}

t_summary() {
  local total=$((T_PASS + T_FAIL))
  printf '%s: %d/%d passed\n' "$T_NAME" "$T_PASS" "$total"
  [ "$T_FAIL" -eq 0 ]
}
