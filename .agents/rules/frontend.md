# Frontend Rules

**Applies to:** `/src/frontend/*`, `*.tsx`, `*.ts`, `*.css`

## 1. Tech Stack
* **Framework:** React / Next.js
* **Styling:** Vanilla CSS (or Tailwind if specified by user)
* **Language:** TypeScript (Strict mode enabled)

## 2. Component Design
* Build functional components utilizing React Hooks.
* Avoid class components entirely.
* Keep components small and focused on a single responsibility.
* Ensure all interactive elements have proper `aria-` labels and adhere to standard accessibility (a11y) rules.

## 3. State Management
* Lift state up to the closest common ancestor when state needs to be shared.
* Prefer Context API for global state unless Redux or Zustand is already explicitly established in the project.

## 4. Aesthetics Guidelines
* Use vibrant colors, sleek dark modes, and modern web design techniques to create a stunning first impression. 
* Add subtle micro-animations (hover effects, transitions) for enhanced user experience.
* Avoid generic colors; stick to tailored palettes or established CSS variables.
