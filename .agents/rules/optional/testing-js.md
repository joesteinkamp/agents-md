---
description: JavaScript / TypeScript test framework specifics. Opt-in.
globs: ["**/*.test.ts", "**/*.test.tsx", "**/*.test.js", "**/*.spec.ts", "**/*.spec.tsx", "**/*.spec.js"]
alwaysApply: false
---

# JavaScript Testing Rules (optional)

Enable this file by listing it under **Enabled optional rules** in `AGENTS.md`. It layers on top of the always-on testing rules in `AGENTS.md` and assumes those principles apply.

## Frameworks
- Unit / integration: Jest or Vitest.
- End-to-end: Playwright preferred; Cypress acceptable if already established.

## File layout
- Pair tests with implementation: `utils.ts` → `utils.test.ts`. Place E2E specs under `tests/e2e/` or `e2e/`.

## Conventions
- Use `describe` blocks for the unit under test, `it`/`test` for behaviors.
- Prefer `expect(...).toEqual(...)` over `toBe` for objects; reserve `toBe` for primitives and reference identity.
- Avoid `any` in test code — type leaks here predict type leaks in production.
