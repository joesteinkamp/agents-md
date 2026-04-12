# Testing Rules

**Applies to:** `*.test.ts`, `*.spec.ts`, `/tests/*`

## 1. Frameworks
* **Unit Tests:** Jest or Vitest
* **E2E Tests:** Playwright or Cypress

## 2. Guidelines
* Ensure a test file exists alongside the implementation file it tests (e.g., `utils.ts` -> `utils.test.ts`).
* Write tests that focus on user behavior and public API contracts, not internal implementation details.
* Mock external dependencies and network requests to ensure tests are fast and deterministic.
* All new features must be accompanied by relevant unit tests.

## 3. Running Tests
* Before completing a code change, run the test suite and fix any failing tests related to your changes.
