---
description: Entry point for AI agents working in this project.
alwaysApply: true
---

# AGENTS.md

This file is the entry point for any AI agent, coding assistant, or autonomous tool working in this repository. Read it first.

## The four-file system

This project uses a four-file scaffolding for agent context. Each file has a distinct purpose; together they cover what an agent needs to act well.

| File         | Answers                          | Read before                                |
| ------------ | -------------------------------- | ------------------------------------------ |
| `AGENTS.md`  | How do agents work here?         | Any task. Always.                          |
| `PRODUCT.md` | What are we building, and why?   | Scoping, prioritization, requirements work |
| `DESIGN.md`  | How should it look and feel?     | UX, visual, interaction decisions          |
| `CODE.md`    | How is the code organized?       | Architectural, stack, or pattern decisions |

If a referenced file is missing, flag the gap to the user before proceeding on that dimension rather than improvising.

## Precedence

When sources conflict, the higher-numbered rule wins.

1. Explicit instructions from the user in the current session
2. Nearest `AGENTS.md` (directory-local overrides parent)
3. `.agents/rules/*` whose `globs` match the file or path being edited
4. This root file
5. `.agents/rules/optional/*` — only if listed under **Enabled optional rules** below
6. Tool defaults and training-data conventions

When two sources at the same level disagree, prefer the more specific one.

## `.agents/` index

### Rules — passive constraints applied while editing

| File                          | Scope                                              |
| ----------------------------- | -------------------------------------------------- |
| `rules/git.md`                | Branches, commits, pushes, secrets                 |
| `rules/security.md`           | Universal security baseline                        |
| `rules/testing.md`            | Testing principles (framework-agnostic)            |
| `rules/optional/*`            | Opt-in. See **Enabled optional rules** below.      |

### Skills — active workflows triggered by name

| File                              | Trigger phrase             |
| --------------------------------- | -------------------------- |
| `skills/commit-push-merge.md`     | "commit, push, and merge"  |

See `.agents/README.md` for the file schema and how to add new rules or skills.

## Enabled optional rules

Projects edit this section to opt into rules under `.agents/rules/optional/`. Default: none enabled.

- _(none)_

Available optional rules:
- `frontend-react.md` — React / Next.js component and styling conventions
- `testing-js.md` — JavaScript test framework specifics (Jest, Vitest, Playwright, Cypress)

## Baseline etiquette

These apply to every task unless the user explicitly overrides them.

- Never push to `main` or `master` directly. Always work on a branch.
- Never commit secrets, credentials, tokens, or `.env*` files.
- Run the test suite before declaring a change complete.
- Prefer a new commit over amending or force-pushing once a branch is shared.
- Don't bypass hooks (`--no-verify`, `--no-gpg-sign`) without explicit user approval.
- Investigate root causes; don't suppress errors or warnings to silence them.

## Nested `AGENTS.md`

Subdirectories may contain their own `AGENTS.md` for area-specific overrides. Under the precedence rules above, the nearest one wins.

## Cross-tool compatibility

`AGENTS.md` is the single source of truth. Tool-specific entry points (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, etc.) are thin pointers to this file. If you adopt another agent tool, add its expected entry point as a stub that references `AGENTS.md`.

## Versioning

This kit follows semver. See `CHANGELOG.md` for history. Pin to a tagged version when stability matters.
