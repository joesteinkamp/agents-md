# agents-md

A best-in-breed `AGENTS.md` starter kit. Drop it into any project to give AI coding agents (Claude Code, Cursor, Copilot, Aider, etc.) a consistent, opinionated set of rules and skills.

This kit is one of four files in a project's core agent scaffolding:

| File         | Owns                              |
| ------------ | --------------------------------- |
| `AGENTS.md`  | How agents work — *this kit*       |
| `PRODUCT.md` | What's being built and why         |
| `DESIGN.md`  | How it should look and feel        |
| `CODE.md`    | How the code is organized          |

## Install

In the root of the target project:

```bash
/path/to/agents-md/install.sh .          # copy without overwriting
/path/to/agents-md/install.sh . --force  # copy and overwrite
```

The script copies:

- `AGENTS.md`
- `CLAUDE.md`
- `.cursorrules`
- `.github/copilot-instructions.md`
- `.agents/`

After install, edit `AGENTS.md` in the target project to:
1. Add entries under "Enabled optional rules" if you want any of `.agents/rules/optional/*` to apply.
2. Append project-specific rules to the always-on section, or drop new files into `.agents/rules/` for glob-scoped rules.

## Layout

```
AGENTS.md                       # entry point + orchestrator + index
CLAUDE.md                       # pointer to AGENTS.md
.cursorrules                    # pointer to AGENTS.md
.github/copilot-instructions.md # pointer to AGENTS.md
.agents/
├── README.md                   # schema for adding rules and skills
├── rules/                      # passive constraints applied while editing
│   └── optional/               # opt-in only
│       ├── frontend-react.md
│       └── testing-js.md
└── skills/                     # active workflows triggered by name
    └── commit-push-merge.md
```

## Cross-tool compatibility

`AGENTS.md` is the source of truth. Tool-specific entry points are thin pointers, so every tool sees the same rules. To add support for another tool, drop in its expected entry-point file as a pointer.

## Versioning

This kit follows [semver](https://semver.org/). Pin to a tag if you need stability across consuming projects:

```bash
git -C agents-md checkout v0.1.0
```

See [`CHANGELOG.md`](./CHANGELOG.md) for history.

## Adding rules and skills

See [`.agents/README.md`](./.agents/README.md) for the file schema (frontmatter, sections, glob conventions).

## Tests

This repo has two test suites:

- `tests/run.sh` — unit tests for the kit's own shell code (`install.sh`, the eval helpers, pointer-file freshness). Fast and deterministic, no API spend.
- `evals/run.sh` — behavioral evals that run mock or real agents against tasks and score rule adherence. See [`evals/README.md`](./evals/README.md).

Run both before opening a PR.
