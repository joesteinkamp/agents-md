# Changelog

All notable changes to this kit will be documented here. The format follows [Keep a Changelog](https://keepachangelog.com/), and the kit follows [semver](https://semver.org/).

## [Unreleased]

### Changed
- Always-on baselines (`git`, `security`, `testing`) inlined into `AGENTS.md` so the entry point carries the universal rules directly. `.agents/rules/` is now reserved for glob-scoped and opt-in rules.

### Removed
- `.agents/rules/git.md`, `.agents/rules/security.md`, `.agents/rules/testing.md` — superseded by the inlined sections in `AGENTS.md`.
- "Baseline etiquette" section in `AGENTS.md` — its items are covered by the inlined Git, Security, and Testing rules.

### Added
- Four-file orchestration: `AGENTS.md` now indexes and references `PRODUCT.md`, `DESIGN.md`, and `CODE.md`, with explicit guidance on when to read each.
- Explicit precedence rules for resolving conflicts between instruction sources.
- Tech-neutral default rules: `git.md`, `security.md`, and a rewritten `testing.md` focused on principles rather than frameworks.
- `.agents/rules/optional/` directory for tech-specific rules that projects opt into via `AGENTS.md`.
- `.agents/README.md` describing the file schema (frontmatter, sections) for adding new rules and skills.
- YAML frontmatter (`description`, `globs`, `alwaysApply`) on every rule and skill file for cross-tool parsing.
- Cross-tool pointer files: `.cursorrules`, `.github/copilot-instructions.md`. `CLAUDE.md` rewritten as a thin pointer.
- `install.sh` distribution script that copies the kit into a target project, with `--force` for overwrites.
- `README.md` with install, layout, and versioning docs.
- `CHANGELOG.md` (this file).

### Changed
- `frontend.md` moved to `rules/optional/frontend-react.md` and renamed to reflect its tech-specific scope.
- `testing.md` split: tech-neutral principles stay in `rules/testing.md`; framework specifics moved to `rules/optional/testing-js.md`.
- `commit-push-merge.md` annotated as a high-risk skill that requires explicit user invocation.

## [0.1.0] - prior

Initial sketch: `AGENTS.md` plus `.agents/rules/{frontend,testing}.md` and `.agents/skills/commit-push-merge.md`.
