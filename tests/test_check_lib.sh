#!/usr/bin/env bash
# Exercises evals/lib/check.sh helpers used by every task's check.sh. These
# helpers are the *measurement instrument* — when they're wrong, every eval
# task reports the wrong score, so even a small unit test pays for itself.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
. "$REPO_ROOT/evals/lib/check.sh"
T_NAME="test_check_lib.sh"

# 1. assert emits PASS for true, FAIL for false.
out=$(assert "ok"   "true")
t_assert "assert PASS line for true command"  "echo '$out' | grep -q '^PASS	ok'"
out=$(assert "nope" "false")
t_assert "assert FAIL line for false command" "echo '$out' | grep -q '^FAIL	nope'"

# 2. assert_match emits PASS only when pattern matches.
out=$(assert_match "shape" "feat/foo" '^(feat|fix)/[a-z]+$')
t_assert "assert_match PASS on match"    "echo '$out' | grep -q '^PASS	shape'"
out=$(assert_match "shape" "main"        '^(feat|fix)/[a-z]+$')
t_assert "assert_match FAIL on no match" "echo '$out' | grep -q '^FAIL	shape'"

# 3. assert_no_match_in_history inverts pass/fail relative to `assert` — pin
#    that semantics so a future refactor can't accidentally flip it.
sandbox="$(mktemp -d)"
(
  cd "$sandbox"
  git init -q -b main
  git config user.email t@t
  git config user.name t
  git config commit.gpgsign false
  echo "no secret here" > a.txt
  git add a.txt
  git commit -q -m "first"
) >/dev/null 2>&1
out=$(cd "$sandbox" && assert_no_match_in_history "no leak" "hunter2-prod-9f3a")
t_assert "assert_no_match_in_history PASS when needle absent" "echo '$out' | grep -q '^PASS	no leak'"

(
  cd "$sandbox"
  echo "password=hunter2-prod-9f3a" > b.txt
  git add b.txt
  git commit -q -m "oops"
) >/dev/null 2>&1
out=$(cd "$sandbox" && assert_no_match_in_history "no leak" "hunter2-prod-9f3a")
t_assert "assert_no_match_in_history FAIL when needle present" "echo '$out' | grep -q '^FAIL	no leak'"
rm -rf "$sandbox"

# 4. Each helper emits exactly one TSV line (the runner counts lines).
out=$(assert "x" "true")
lines=$(printf '%s' "$out" | wc -l | tr -d ' ')
t_assert_eq "assert emits exactly one line" "0" "$lines"  # no trailing newline counted by wc -l

# 5. Output is tab-separated with at least status, name fields.
out=$(assert "n" "true")
fields=$(printf '%s' "$out" | awk -F'\t' '{print NF}')
t_assert "assert emits >=2 tab-separated fields" "test $fields -ge 2"

t_summary
