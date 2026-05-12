#!/usr/bin/env bash
# Exercises install.sh behaviors that are easy to break by accident.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
T_NAME="test_install.sh"

mk_target() { mktemp -d; }

# 1. Fresh install populates the expected files.
target="$(mk_target)"
"$REPO_ROOT/install.sh" "$target" >/dev/null
t_assert "fresh install copies AGENTS.md"              "test -f '$target/AGENTS.md'"
t_assert "fresh install copies CLAUDE.md"              "test -f '$target/CLAUDE.md'"
t_assert "fresh install copies .cursorrules"           "test -f '$target/.cursorrules'"
t_assert "fresh install copies copilot-instructions"   "test -f '$target/.github/copilot-instructions.md'"
t_assert "fresh install copies .agents/ directory"     "test -d '$target/.agents'"
rm -rf "$target"

# 2. Re-running without --force skips existing files (idempotent, non-destructive).
target="$(mk_target)"
"$REPO_ROOT/install.sh" "$target" >/dev/null
printf 'local edit\n' >> "$target/AGENTS.md"
before_hash=$(sha256sum "$target/AGENTS.md" | awk '{print $1}')
"$REPO_ROOT/install.sh" "$target" >/dev/null
after_hash=$(sha256sum "$target/AGENTS.md" | awk '{print $1}')
t_assert_eq "second run without --force preserves local edits" "$before_hash" "$after_hash"
rm -rf "$target"

# 3. --force overwrites existing files.
target="$(mk_target)"
"$REPO_ROOT/install.sh" "$target" >/dev/null
printf 'local edit\n' >> "$target/AGENTS.md"
"$REPO_ROOT/install.sh" --force "$target" >/dev/null
upstream_hash=$(sha256sum "$REPO_ROOT/AGENTS.md" | awk '{print $1}')
after_force=$(sha256sum "$target/AGENTS.md" | awk '{print $1}')
t_assert_eq "--force overwrites existing files" "$upstream_hash" "$after_force"
rm -rf "$target"

# 4. Refuses to install onto itself.
"$REPO_ROOT/install.sh" "$REPO_ROOT" >/dev/null 2>&1
t_assert "refuses to install onto the kit itself" "test $? -ne 0"

# 5. Missing target directory is a hard error.
"$REPO_ROOT/install.sh" /nonexistent/dir-that-should-not-exist >/dev/null 2>&1
t_assert "missing target dir errors out" "test $? -ne 0"

# 6. Unknown option is rejected.
target="$(mk_target)"
"$REPO_ROOT/install.sh" --bogus "$target" >/dev/null 2>&1
t_assert "unknown option errors out" "test $? -ne 0"
rm -rf "$target"

# 7. Multiple positional args are rejected.
target="$(mk_target)"; target2="$(mk_target)"
"$REPO_ROOT/install.sh" "$target" "$target2" >/dev/null 2>&1
t_assert "extra positional args are rejected" "test $? -ne 0"
rm -rf "$target" "$target2"

t_summary
