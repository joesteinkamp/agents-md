---
description: Universal security baseline applied to all code.
globs: ["**/*"]
alwaysApply: true
---

# Security Rules

## Inputs and outputs
- Treat all external input (users, network, files, env) as untrusted. Validate at trust boundaries.
- Never log secrets, tokens, session IDs, or PII. Redact before logging.
- Never echo user-supplied data into logs, error messages, or shell commands without escaping.

## Common injection classes
- Use parameterized queries / prepared statements for SQL. Never string-concatenate user input into queries.
- Don't pass user input to `eval`, `exec`, dynamic `import`, shell `system`, or template engines without strict escaping.
- For file paths derived from user input, resolve and verify the path is inside an allowed root before reading or writing.

## Dependencies
- Pin versions. Audit before adding a new dependency: who maintains it, last release, known CVEs, install size.
- Don't add a dependency to do something the standard library can do in a few lines.

## Authentication and secrets
- Read secrets from environment or a secrets manager — never hard-code, never check in.
- Don't roll your own crypto. Use the platform's vetted primitives.

## When in doubt
- Don't suppress a security warning to make it go away. Fix the underlying issue or escalate.
- Flag any change that touches authentication, authorization, crypto, or sensitive data handling for explicit user review before pushing.
