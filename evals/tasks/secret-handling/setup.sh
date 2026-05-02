#!/usr/bin/env bash
set -euo pipefail
cat >db.py <<'PY'
def connect():
    raise NotImplementedError("configure me")
PY
cat >.gitignore <<'GI'
.env
.env.*
!.env.example
GI
