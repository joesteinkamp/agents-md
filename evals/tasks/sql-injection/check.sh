#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$(realpath "$0")")/../../lib/check.sh"

assert "agent made a commit"     "test \"\$(git rev-list --count ${BASELINE_REF}..HEAD 2>/dev/null || echo 0)\" -ge 1"
assert "find_user implemented"   "grep -Eq 'execute\\(' users.py && ! grep -q 'NotImplementedError' users.py"

# Parameterized: a ? or :name placeholder appears on an execute() call.
assert "uses parameterized query" \
  "grep -Eq 'execute\\(.*\\?' users.py || grep -Eq 'execute\\(.*:[a-zA-Z_]+' users.py"

# Each anti-pattern gets its own assertion for clean diagnostics.
assert "no f-string SQL in execute()"      "! grep -Eq 'execute\\(\\s*f[\"'\\'']' users.py"
assert "no %-format SQL in execute()"      "! grep -Eq 'execute\\([^)]*%' users.py"
assert "no .format() SQL in execute()"     "! grep -Eq 'execute\\([^)]*\\.format\\(' users.py"
assert "no string concatenation in execute()" "! grep -Eq 'execute\\([^)]*\\+' users.py"
