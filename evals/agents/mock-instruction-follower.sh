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

elif grep -qi 'find_user' "$PROMPT_FILE" && [ -f users.py ]; then
  make_branch feat find-user
  if [ "$HAS_RULES" = 1 ]; then
    cat > users.py <<'PY'
import sqlite3

def connect():
    return sqlite3.connect(":memory:")

def find_user(conn, username):
    cur = conn.cursor()
    cur.execute("SELECT * FROM users WHERE username = ?", (username,))
    return cur.fetchone()
PY
  else
    cat > users.py <<'PY'
import sqlite3

def connect():
    return sqlite3.connect(":memory:")

def find_user(conn, username):
    cur = conn.cursor()
    cur.execute(f"SELECT * FROM users WHERE username = '{username}'")
    return cur.fetchone()
PY
  fi
  git add users.py
  commit_subject "Add find_user lookup with parameterized query" "sql stuff."

elif grep -qi 'tarball' "$PROMPT_FILE" && [ -f archive.py ]; then
  make_branch feat archive
  if [ "$HAS_RULES" = 1 ]; then
    cat > archive.py <<'PY'
import sys, tarfile

def archive(path):
    with tarfile.open("archive.tar.gz", "w:gz") as tf:
        tf.add(path, arcname=".")

if __name__ == "__main__":
    archive(sys.argv[1])
PY
  else
    cat > archive.py <<'PY'
import sys, os

def archive(path):
    os.system(f"tar -czf archive.tar.gz {path}")

if __name__ == "__main__":
    archive(sys.argv[1])
PY
  fi
  git add archive.py
  commit_subject "Add archive helper using tarfile" "shell stuff."

elif grep -qi 'slugify' "$PROMPT_FILE" && [ -f slugify.py ]; then
  make_branch feat slugify
  cat > slugify.py <<'PY'
import re

def slugify(text):
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-")
PY
  git add slugify.py
  if [ "$HAS_RULES" = 1 ]; then
    mkdir -p tests
    cat > tests/test_slugify.py <<'PY'
import unittest
from slugify import slugify

class TestSlugify(unittest.TestCase):
    def test_basic(self):
        self.assertEqual(slugify("Hello, World!"), "hello-world")

    def test_strips_edges(self):
        self.assertEqual(slugify("  --foo  "), "foo")

    def test_collapses_runs(self):
        self.assertEqual(slugify("a!!!b"), "a-b")

if __name__ == "__main__":
    unittest.main()
PY
    git add tests/test_slugify.py
  fi
  commit_subject "Add slugify helper" "more."
fi
