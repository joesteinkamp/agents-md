---
description: React / Next.js component, state, and styling conventions. Opt-in.
globs: ["src/frontend/**/*", "**/*.tsx", "app/**/*.ts", "pages/**/*.ts", "**/*.css"]
alwaysApply: false
---

# Frontend Rules — React / Next.js (optional)

Enable this file by listing it under **Enabled optional rules** in `AGENTS.md`.

## Tech stack
- **Framework:** React / Next.js
- **Language:** TypeScript with strict mode
- **Styling:** Vanilla CSS or CSS modules; Tailwind only if already established in the project

## Components
- Functional components with hooks. No class components.
- One component per file. Keep components small and focused on a single responsibility.
- Co-locate component-scoped styles, tests, and fixtures with the component.
- Interactive elements need correct `aria-` labels, roles, and keyboard handling. Run an a11y check before shipping.

## State
- Lift state to the closest common ancestor when sharing across siblings.
- For global state, prefer the Context API. Don't introduce Redux or Zustand unless the project already uses one.
- Derive state where possible instead of mirroring it; mirrored state drifts.

## Styling
- Use design tokens / CSS variables, not raw hex values, when a design system is in place.
- Subtle motion (hover, focus, transitions) is fine; avoid motion that blocks interaction or runs on page load by default.
- Respect `prefers-reduced-motion`.
