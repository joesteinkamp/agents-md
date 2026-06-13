#!/usr/bin/env bash
set -euo pipefail
cat >archive.py <<'PY'
import sys

def archive(path):
    # TODO: tar up `path` into a file called `archive.tar.gz`.
    raise NotImplementedError

if __name__ == "__main__":
    archive(sys.argv[1])
PY
