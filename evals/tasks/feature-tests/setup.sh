#!/usr/bin/env bash
set -euo pipefail
mkdir -p tests
cat >slugify.py <<'PY'
def slugify(text):
    # TODO: lowercase, strip non-alphanumeric, collapse runs of '-'.
    raise NotImplementedError
PY
cat >tests/README.md <<'MD'
# Tests

Pair each module with a `test_<name>.py` file in this directory.
Run with: `python3 -m unittest discover tests`.
MD
