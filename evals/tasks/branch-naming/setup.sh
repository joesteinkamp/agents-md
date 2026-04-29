#!/usr/bin/env bash
set -euo pipefail
cat >cli.py <<'PY'
import sys

def main(argv):
    print("hello, world")

if __name__ == "__main__":
    main(sys.argv[1:])
PY
