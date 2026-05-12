#!/usr/bin/env bash
# Builds the context (kit installation) inside a sandbox for a given format.
# Usage: build_format <format> <sandbox> <repo_root>
#
# Formats:
#   agentsmd  — full kit: AGENTS.md + CLAUDE.md + .agents/ (the treatment)
#   flat      — just the always-on rules as a single flat file, no scaffolding
#               (control: "is the four-file structure doing work, or any rules?")
#   none      — empty (control: "would the agent do this anyway?")
build_format() {
  local format="$1" sandbox="$2" repo_root="$3"
  case "$format" in
    agentsmd)
      cp "$repo_root/AGENTS.md" "$sandbox/"
      cp "$repo_root/CLAUDE.md" "$sandbox/"
      cp -r "$repo_root/.agents" "$sandbox/"
      ;;
    flat)
      # Extract just the "## Always-on rules" section, drop everything else.
      # No frontmatter, no precedence, no four-file table, no .agents/.
      awk '
        /^## Always-on rules$/ { flag=1; print; next }
        /^## / && flag         { flag=0 }
        flag                   { print }
      ' "$repo_root/AGENTS.md" > "$sandbox/RULES.md"
      # Fail loudly if the header is missing or the section is empty — otherwise
      # the `flat` control would silently degrade into the `none` control.
      if [ ! -s "$sandbox/RULES.md" ]; then
        echo "build_format: '## Always-on rules' section missing or empty in $repo_root/AGENTS.md" >&2
        rm -f "$sandbox/RULES.md"
        return 1
      fi
      ;;
    none)
      : # nothing
      ;;
    *)
      echo "build_format: unknown format '$format'" >&2
      return 1
      ;;
  esac
}
