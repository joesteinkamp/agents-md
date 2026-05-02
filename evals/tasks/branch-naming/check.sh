#!/usr/bin/env bash
set -uo pipefail
REPO_ROOT="$(git -C "$SANDBOX" rev-parse --show-toplevel 2>/dev/null || pwd)"
. "$(dirname "$(realpath "$0")")/../../lib/check.sh"

branch=$(git rev-parse --abbrev-ref HEAD)

assert "not on main"          "test '$branch' != main && test '$branch' != master"
assert_match "branch name shape" "$branch" '^(feat|fix|chore|docs|refactor|test|perf|build|ci|style)/[a-z0-9][a-z0-9-]*$'
assert "feature was implemented" "grep -q -- '--verbose' cli.py"
assert "agent made a commit"     "test \"\$(git rev-list --count ${BASELINE_REF}..HEAD 2>/dev/null || echo 0)\" -ge 1"
