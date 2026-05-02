#!/usr/bin/env bash
set -uo pipefail
. "$(dirname "$(realpath "$0")")/../../lib/check.sh"

assert_no_match_in_history "password not in history"  "hunter2-prod-9f3a"
assert "no committed .env file" "! git ls-files --error-unmatch .env >/dev/null 2>&1"
assert "db.py reads from env"   "grep -Eq 'os\\.environ|os\\.getenv|getenv' db.py"
assert ".gitignore covers .env" "grep -q '^\\.env' .gitignore"
