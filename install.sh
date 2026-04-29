#!/usr/bin/env bash
# install.sh — copy the AGENTS.md kit into a target project.
#
# Usage:
#   ./install.sh [target-dir] [--force]
#
# If target-dir is omitted, defaults to the current working directory.
# By default, existing files are not overwritten. Pass --force to overwrite.
#
# Files copied:
#   AGENTS.md
#   CLAUDE.md
#   .cursorrules
#   .github/copilot-instructions.md
#   .agents/  (entire directory)

set -euo pipefail

force=0
target=""

for arg in "$@"; do
  case "$arg" in
    --force|-f) force=1 ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
    *)
      if [[ -n "$target" ]]; then
        echo "Unexpected argument: $arg" >&2
        exit 2
      fi
      target="$arg"
      ;;
  esac
done

target="${target:-$PWD}"
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$target" ]]; then
  echo "Target directory does not exist: $target" >&2
  exit 1
fi

if [[ "$src" == "$target" ]]; then
  echo "Refusing to install onto the kit itself." >&2
  exit 1
fi

copy_file() {
  local rel="$1"
  local from="$src/$rel"
  local to="$target/$rel"
  if [[ -e "$to" && "$force" -ne 1 ]]; then
    echo "skip   $rel (exists; use --force to overwrite)"
    return
  fi
  mkdir -p "$(dirname "$to")"
  cp "$from" "$to"
  echo "copied $rel"
}

copy_dir() {
  local rel="$1"
  local from="$src/$rel"
  local to="$target/$rel"
  if [[ -e "$to" && "$force" -ne 1 ]]; then
    echo "skip   $rel/ (exists; use --force to overwrite)"
    return
  fi
  rm -rf "$to"
  mkdir -p "$(dirname "$to")"
  cp -R "$from" "$to"
  echo "copied $rel/"
}

copy_file "AGENTS.md"
copy_file "CLAUDE.md"
copy_file ".cursorrules"
copy_file ".github/copilot-instructions.md"
copy_dir  ".agents"

echo
echo "Done. Edit AGENTS.md in your project to set 'Enabled optional rules' and add project-specific rules to the always-on section."
