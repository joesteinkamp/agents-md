---
description: Testing principles. Framework-agnostic.
globs: ["**/*test*", "**/*spec*", "**/tests/**", "**/__tests__/**"]
alwaysApply: true
---

# Testing Rules

## Principles
- Test behavior and public contracts, not internal structure. Tests that mirror implementation break on refactor and provide false confidence.
- Colocate tests with the code under test when the language and tooling permit.
- Each new feature ships with tests covering the golden path and at least one meaningful edge case.
- Mock external dependencies (network, filesystem, time, randomness) so tests are fast and deterministic.

## Discipline
- Run the relevant test suite before declaring a change complete. For UI changes, also exercise the feature in a running app — type-checks and unit tests verify code correctness, not feature correctness.
- A failing test is a higher-priority signal than a passing one. Don't disable, skip, or weaken assertions to make a test pass — fix the root cause.
- Don't add a test purely to raise coverage numbers. Each test should describe a behavior worth protecting.

## Test data
- Prefer factories or builders over shared fixtures that drift over time.
- Avoid sleeps and wall-clock waits. Use fake timers or explicit synchronization.
