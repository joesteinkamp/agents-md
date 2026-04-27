---
description: Version control conventions for branches, commits, and pushes.
globs: ["**/*"]
alwaysApply: true
---

# Git Rules

## Branches
- Work on a branch. Never commit directly to `main` or `master`.
- Name branches `<type>/<short-description>` (e.g. `feat/user-search`, `fix/login-redirect`, `chore/upgrade-deps`, `docs/agents-readme`).

## Commits
- Subject line in the imperative mood, ≤72 characters, no trailing period (e.g. `Add user search endpoint`).
- One logical change per commit. Don't bundle unrelated edits.
- Explain *why* in the body when the *what* isn't self-evident from the diff.
- Don't `git commit --amend` or rebase a branch after others may have pulled it.

## Pushes
- Use `git push -u origin <branch-name>` on the first push so upstream is set.
- Never `--force` push to a shared branch. Use `--force-with-lease` only on your own feature branch and only when necessary.
- Don't bypass hooks (`--no-verify`, `--no-gpg-sign`) without explicit user approval. If a hook fails, fix the root cause.

## Secrets and sensitive files
- Never commit `.env*`, credentials, API keys, tokens, certificates, or private keys.
- If you discover a leaked secret in history, stop and notify the user — rotation is required, not just removal.

## Pull requests
- Open PRs as ready for review (not draft) unless the user asks otherwise.
- Title under 70 characters; put detail in the body.
