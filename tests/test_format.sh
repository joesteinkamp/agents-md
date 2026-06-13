#!/usr/bin/env bash
# Exercises evals/lib/format.sh — the function that builds context for each
# format variant. Most important: the `flat` extraction must not silently
# produce an empty RULES.md if the source AGENTS.md is restructured.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
. "$REPO_ROOT/evals/lib/format.sh"
T_NAME="test_format.sh"

# 1. agentsmd installs the kit files.
sandbox="$(mktemp -d)"
build_format agentsmd "$sandbox" "$REPO_ROOT"
t_assert "agentsmd installs AGENTS.md"       "test -f '$sandbox/AGENTS.md'"
t_assert "agentsmd installs CLAUDE.md"       "test -f '$sandbox/CLAUDE.md'"
t_assert "agentsmd installs .agents/"        "test -d '$sandbox/.agents'"
t_assert "agentsmd does NOT create RULES.md" "! test -f '$sandbox/RULES.md'"
rm -rf "$sandbox"

# 2. flat extracts the always-on rules into a non-empty RULES.md.
sandbox="$(mktemp -d)"
build_format flat "$sandbox" "$REPO_ROOT"
t_assert "flat creates RULES.md"             "test -f '$sandbox/RULES.md'"
t_assert "flat RULES.md is non-empty"        "test -s '$sandbox/RULES.md'"
t_assert "flat RULES.md contains git rules"  "grep -q 'Branches' '$sandbox/RULES.md'"
t_assert "flat RULES.md contains security rules" "grep -q 'injection' '$sandbox/RULES.md'"
t_assert "flat RULES.md contains testing rules"  "grep -q 'Testing' '$sandbox/RULES.md'"
t_assert "flat does NOT include AGENTS.md"   "! test -f '$sandbox/AGENTS.md'"
t_assert "flat does NOT include .agents/"    "! test -d '$sandbox/.agents'"
rm -rf "$sandbox"

# 3. flat fails LOUDLY if the header is missing — otherwise the `flat` control
#    silently degrades into the `none` control, hiding any kit regression.
fake_root="$(mktemp -d)"
mkdir -p "$fake_root/.agents"
cat > "$fake_root/AGENTS.md" <<'MD'
# AGENTS.md
Some content without the expected header.
MD
cat > "$fake_root/CLAUDE.md" <<'MD'
# CLAUDE.md
MD
sandbox="$(mktemp -d)"
if build_format flat "$sandbox" "$fake_root" >/dev/null 2>&1; then
  rc=0
else
  rc=1
fi
t_assert_eq "flat returns non-zero when header missing" "1" "$rc"
t_assert    "flat removes empty RULES.md on failure"    "! test -f '$sandbox/RULES.md'"
rm -rf "$sandbox" "$fake_root"

# 4. none produces nothing.
sandbox="$(mktemp -d)"
build_format none "$sandbox" "$REPO_ROOT"
t_assert "none produces no AGENTS.md" "! test -f '$sandbox/AGENTS.md'"
t_assert "none produces no RULES.md"  "! test -f '$sandbox/RULES.md'"
t_assert "none produces no .agents/"  "! test -d '$sandbox/.agents'"
rm -rf "$sandbox"

# 5. unknown format returns non-zero.
sandbox="$(mktemp -d)"
build_format bogus "$sandbox" "$REPO_ROOT" >/dev/null 2>&1
t_assert "unknown format returns non-zero" "test $? -ne 0"
rm -rf "$sandbox"

t_summary
