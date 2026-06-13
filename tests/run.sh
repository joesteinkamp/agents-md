#!/usr/bin/env bash
# Unit-test runner for the kit's own shell code. Complements `evals/run.sh`
# (which measures agent behavior). Discovers every `tests/test_*.sh`, runs
# each in a subshell, and exits non-zero if any fails.
#
# Usage:
#   tests/run.sh                 # all tests
#   tests/run.sh test_install    # one test by stem
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

filter="${1:-}"
files=()
for f in test_*.sh; do
  [ -f "$f" ] || continue
  if [ -n "$filter" ] && [[ "$f" != "$filter"* ]]; then continue; fi
  files+=("$f")
done

if [ ${#files[@]} -eq 0 ]; then
  echo "no test files matched" >&2
  exit 2
fi

fail=0
for f in "${files[@]}"; do
  echo "==> $f"
  if ! bash "$f"; then
    fail=$((fail + 1))
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "All ${#files[@]} test files passed."
  exit 0
else
  echo "$fail of ${#files[@]} test files failed." >&2
  exit 1
fi
