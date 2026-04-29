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
4. This root file (including the always-on rules below)
5. `.agents/rules/optional/*` — only if listed under **Enabled optional rules** below
6. Tool defaults and training-data conventions

When two sources at the same level disagree, prefer the more specific one.

## Always-on rules

These apply to every task in every project that installs the kit. They override tool defaults but yield to anything more specific (nested `AGENTS.md`, matching `.agents/rules/*`, or explicit user instruction).

### Git

**Branches**
- Work on a branch. Never commit directly to `main` or `master`.
- Name branches `<type>/<short-description>` (e.g. `feat/user-search`, `fix/login-redirect`, `chore/upgrade-deps`, `docs/agents-readme`).

**Commits**
- Subject line in the imperative mood, ≤72 characters, no trailing period (e.g. `Add user search endpoint`).
- One logical change per commit. Don't bundle unrelated edits.
- Explain *why* in the body when the *what* isn't self-evident from the diff.
- Don't `git commit --amend` or rebase a branch after others may have pulled it.

**Pushes**
- Use `git push -u origin <branch-name>` on the first push so upstream is set.
- Never `--force` push to a shared branch. Use `--force-with-lease` only on your own feature branch and only when necessary.
- Don't bypass hooks (`--no-verify`, `--no-gpg-sign`) without explicit user approval. If a hook fails, fix the root cause.

**Secrets and sensitive files**
- Never commit `.env*`, credentials, API keys, tokens, certificates, or private keys.
- If you discover a leaked secret in history, stop and notify the user — rotation is required, not just removal.

**Pull requests**
- Open PRs as ready for review (not draft) unless the user asks otherwise.
- Title under 70 characters; put detail in the body.

### Security

**Inputs and outputs**
- Treat all external input (users, network, files, env) as untrusted. Validate at trust boundaries.
- Never log secrets, tokens, session IDs, or PII. Redact before logging.
- Never echo user-supplied data into logs, error messages, or shell commands without escaping.

**Common injection classes**
- Use parameterized queries / prepared statements for SQL. Never string-concatenate user input into queries.
- Don't pass user input to `eval`, `exec`, dynamic `import`, shell `system`, or template engines without strict escaping.
- For file paths derived from user input, resolve and verify the path is inside an allowed root before reading or writing.

**Dependencies**
- Pin versions. Audit before adding a new dependency: who maintains it, last release, known CVEs, install size.
- Don't add a dependency to do something the standard library can do in a few lines.

**Authentication and secrets**
- Read secrets from environment or a secrets manager — never hard-code, never check in.
- Don't roll your own crypto. Use the platform's vetted primitives.

**When in doubt**
- Don't suppress a security warning to make it go away. Fix the underlying issue or escalate.
- Flag any change that touches authentication, authorization, crypto, or sensitive data handling for explicit user review before pushing.

### Testing

**Principles**
- Test behavior and public contracts, not internal structure. Tests that mirror implementation break on refactor and provide false confidence.
- Colocate tests with the code under test when the language and tooling permit.
- Each new feature ships with tests covering the golden path and at least one meaningful edge case.
- Mock external dependencies (network, filesystem, time, randomness) so tests are fast and deterministic.

**Discipline**
- Run the relevant test suite before declaring a change complete. For UI changes, also exercise the feature in a running app — type-checks and unit tests verify code correctness, not feature correctness.
- A failing test is a higher-priority signal than a passing one. Don't disable, skip, or weaken assertions to make a test pass — fix the root cause.
- Don't add a test purely to raise coverage numbers. Each test should describe a behavior worth protecting.

**Test data**
- Prefer factories or builders over shared fixtures that drift over time.
- Avoid sleeps and wall-clock waits. Use fake timers or explicit synchronization.

## `.agents/` index

The always-on rules above are inlined here. `.agents/` holds the rest: project-extensible rules, opt-in rules, and named skills.

### Rules — passive constraints applied while editing

| File                          | Scope                                              |
| ----------------------------- | -------------------------------------------------- |
| `rules/*.md`                  | Project-added rules. Empty by default — extend here. |
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

## Nested `AGENTS.md`

Subdirectories may contain their own `AGENTS.md` for area-specific overrides. Under the precedence rules above, the nearest one wins.

## Cross-tool compatibility

`AGENTS.md` is the single source of truth. Tool-specific entry points (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, etc.) are thin pointers to this file. If you adopt another agent tool, add its expected entry point as a stub that references `AGENTS.md`.

## Versioning

This kit follows semver. See `CHANGELOG.md` for history. Pin to a tagged version when stability matters.
