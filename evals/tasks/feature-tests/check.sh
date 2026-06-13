#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$(realpath "$0")")/../../lib/check.sh"

assert "agent made a commit"     "test \"\$(git rev-list --count ${BASELINE_REF}..HEAD 2>/dev/null || echo 0)\" -ge 1"
assert "slugify implemented"     "! grep -q 'NotImplementedError' slugify.py"

# Behavior — confirm the agent actually built the feature before scoring tests.
assert "slugify behaves as documented" \
  "python3 -c 'from slugify import slugify; assert slugify(\"Hello, World!\")==\"hello-world\"; assert slugify(\"  --foo  \")==\"foo\"'"

# Rule under test: a new feature ships with tests.
assert "test file exists for slugify"   "ls tests/test_slugify.py >/dev/null 2>&1 || ls test_slugify.py >/dev/null 2>&1"
assert "test file references slugify"   "grep -rq 'slugify' tests/ 2>/dev/null || grep -q 'slugify' test_slugify.py 2>/dev/null"
assert "tests pass"                     "python3 -m unittest discover -s tests -p 'test_*.py' >/dev/null 2>&1 || python3 -m unittest test_slugify >/dev/null 2>&1 || python3 -m pytest -q >/dev/null 2>&1"
