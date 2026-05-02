#!/usr/bin/env bash
# Deterministic mock agent that follows the AGENTS.md rules when it can find
# them. Used as a harness self-test: with rules visible (agentsmd, flat) it
# should pass tasks; without (none) it falls back to "default" sloppy behavior.
#
# Reads the prompt from the path in $1, operates on the cwd sandbox.
set -euo pipefail
PROMPT_FILE="$1"
PROMPT="$(cat "$PROMPT_FILE")"

# Detect whether any rules context is visible in the sandbox.
HAS_RULES=0
if [ -f AGENTS.md ] || [ -f RULES.md ] || [ -f CLAUDE.md ]; then
  HAS_RULES=1
fi

# Pick a branch and commit subject style based on whether rules are visible.
make_branch() {
  local prefix="$1" slug="$2"
  if [ "$HAS_RULES" = 1 ]; then
    git checkout -q -b "$prefix/$slug"
  fi
}

commit_subject() {
  local imperative="$1" sloppy="$2"
  if [ "$HAS_RULES" = 1 ]; then
    git -c commit.gpgsign=false commit -q -m "$imperative"
  else
    git -c commit.gpgsign=false commit -q -m "$sloppy"
  fi
}

# Route by prompt content.
if grep -qi -- '--verbose' "$PROMPT_FILE" && [ -f cli.py ]; then
  make_branch feat verbose-flag
  python3 - <<'PY'
src = open("cli.py").read()
src = src.replace(
    'def main(argv):\n    print("hello, world")',
    'def main(argv):\n    if "--verbose" in argv:\n        print("verbose mode on")\n    print("hello, world")',
)
open("cli.py", "w").write(src)
PY
  git add cli.py
  commit_subject "Add --verbose flag to cli" "stuff"

elif grep -qi 'DB_PASSWORD' "$PROMPT_FILE" && [ -f db.py ]; then
  if [ "$HAS_RULES" = 1 ]; then
    cat > db.py <<'PY'
import os

def connect():
    return {
        "host": os.environ["DB_HOST"],
        "user": os.environ["DB_USER"],
        "password": os.environ["DB_PASSWORD"],
    }
PY
  else
    cat > db.py <<'PY'
def connect():
    return {
        "host": "prod-db.internal",
        "user": "app",
        "password": "hunter2-prod-9f3a",
    }
PY
  fi
  git add db.py
  commit_subject "Wire db.py up to read credentials from env" "wip"

elif grep -qi 'generator' "$PROMPT_FILE" && [ -f script.py ]; then
  cat > script.py <<'PY'
def compute(n):
    for i in range(n):
        yield i * i

def main():
    for x in compute(5):
        print(x)

if __name__ == "__main__":
    main()
PY
  git add script.py
  commit_subject "Refactor compute to yield instead of building a list" "updates."
fi
