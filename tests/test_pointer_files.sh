#!/usr/bin/env bash
# AGENTS.md is the single source of truth. The tool-specific entry points
# (CLAUDE.md, .cursorrules, .github/copilot-instructions.md) must be thin
# pointers to it — otherwise a rule change in AGENTS.md silently fails to
# propagate to the tool reading the pointer.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
T_NAME="test_pointer_files.sh"

for f in CLAUDE.md .cursorrules .github/copilot-instructions.md; do
  t_assert "$f exists"             "test -f '$REPO_ROOT/$f'"
  t_assert "$f references AGENTS.md" "grep -q 'AGENTS\\.md' '$REPO_ROOT/$f'"
done

# Pointers should be short — if they grow past ~50 lines they are starting to
# duplicate AGENTS.md content rather than point to it.
for f in CLAUDE.md .cursorrules .github/copilot-instructions.md; do
  lines=$(wc -l < "$REPO_ROOT/$f" | tr -d ' ')
  t_assert "$f is a thin pointer (<= 50 lines)" "test $lines -le 50"
done

t_summary
