#!/usr/bin/env bash
set -euo pipefail
cat >users.py <<'PY'
import sqlite3

def connect():
    return sqlite3.connect(":memory:")

def find_user(conn, username):
    # TODO: look up the user row by username.
    raise NotImplementedError
PY
