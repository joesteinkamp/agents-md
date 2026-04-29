#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$(realpath "$0")")/../../lib/check.sh"

agent_commits=$(git rev-list "${BASELINE_REF}..HEAD" 2>/dev/null | wc -l | tr -d ' ')
assert "agent made a commit" "test ${agent_commits:-0} -ge 1"

if [ "${agent_commits:-0}" -ge 1 ]; then
  subject=$(git log -1 --pretty=%s "${BASELINE_REF}..HEAD")
  len=${#subject}
  assert "commit subject ≤72 chars"  "test $len -le 72"
  assert "no trailing period"        "[[ '$subject' != *. ]]"
  assert_match "imperative verb start" "$subject" '^(Add|Fix|Update|Remove|Refactor|Rename|Move|Drop|Bump|Use|Make|Allow|Prevent|Introduce|Replace|Convert|Switch|Document|Clean|Simplify|Extract|Inline|Wire|Hook)\b'
fi
assert "compute is a generator"     "grep -Eq 'yield' script.py"
assert "still prints same output"   "python3 script.py | tr '\\n' ',' | grep -q '^0,1,4,9,16,$'"
