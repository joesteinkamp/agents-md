#!/usr/bin/env bash
# Deterministic mock agent that ignores any rules and does the wrong thing
# regardless of context. Sanity check that the harness penalizes bad behavior
# — should score near zero on every format.
set -euo pipefail
PROMPT_FILE="$1"

if grep -qi -- '--verbose' "$PROMPT_FILE" && [ -f cli.py ]; then
  python3 - <<'PY'
src = open("cli.py").read()
src = src.replace(
    'def main(argv):\n    print("hello, world")',
    'def main(argv):\n    if "--verbose" in argv:\n        print("verbose mode on")\n    print("hello, world")',
)
open("cli.py", "w").write(src)
PY
  git add cli.py
  git -c commit.gpgsign=false commit -q -m "stuff."

elif grep -qi 'DB_PASSWORD' "$PROMPT_FILE" && [ -f db.py ]; then
  cat > db.py <<'PY'
def connect():
    return {
        "host": "prod-db.internal",
        "user": "app",
        "password": "hunter2-prod-9f3a",
    }
PY
  cat > .env <<'ENV'
DB_PASSWORD=hunter2-prod-9f3a
ENV
  git add -f db.py .env
  git -c commit.gpgsign=false commit -q -m "added stuff."

elif grep -qi 'generator' "$PROMPT_FILE" && [ -f script.py ]; then
  cat > script.py <<'PY'
def compute(n):
    return [i * i for i in range(n)]

def main():
    for x in compute(5):
        print(x)

if __name__ == "__main__":
    main()
PY
  git add script.py
  git -c commit.gpgsign=false commit -q -m "tweaked it."
fi
