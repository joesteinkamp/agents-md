# `.agents/` — schema and conventions

This directory holds glob-scoped rules, opt-in rules, and named skills. Always-on baselines (git, security, testing) live inline in the root `AGENTS.md`. Use this directory for rules that should only activate against matching files, or that callers should opt into explicitly.

## Layout

```
.agents/
├── rules/
│   ├── *.md            # glob-scoped rules — extend per project
│   └── optional/
│       └── *.md        # opt-in rules — apply only when listed in AGENTS.md
└── skills/
    └── *.md            # active workflows triggered by name
```

## Rules vs. skills

| Aspect       | Rule                                              | Skill                                                       |
| ------------ | ------------------------------------------------- | ----------------------------------------------------------- |
| When applied | Passively, while editing matching files           | Actively, when the user invokes it by name                  |
| Scope        | Constraint or convention (do this, don't do that) | A workflow or sequence of actions                           |
| Example      | `frontend-react.md` — component / styling conventions | `commit-push-merge.md` — commit, push, open PR, auto-merge  |

If you find yourself describing a multi-step procedure in a rule, it probably belongs in `skills/`. If you find yourself writing constraints inside a skill, those probably belong in `rules/`.

## File schema

Every file in `rules/` and `skills/` starts with YAML frontmatter, followed by Markdown.

### Rule frontmatter

```yaml
---
description: One-line summary of what this rule covers.
globs: ["**/*.ts", "src/**/*"]   # paths or patterns this rule applies to
alwaysApply: false               # true loads regardless of globs; default false
---
```

- `description`: short, human-readable; surfaced in tool UIs.
- `globs`: array of paths or glob patterns. Project-wide concerns belong inline in `AGENTS.md` rather than as a `["**/*"]` rule file.
- `alwaysApply`: `false` for glob-scoped and optional rules. Reserve `true` for the rare case that must load regardless of the file in scope.

### Skill frontmatter

```yaml
---
description: One-line summary of what the skill does.
trigger: "natural-language phrase the user says"
risk: low | medium | high        # high if it bypasses review, force-pushes, deletes data, etc.
---
```

## Style

- Lead with the rule, then the rationale. Don't bury the rule in prose.
- Bullets over paragraphs. Most agents and most humans skim.
- One concept per file. If a file covers multiple unrelated areas, split it.
- Tech-neutral by default. Anything stack-specific belongs in `rules/optional/`.
- Filenames are lowercase with hyphens (`commit-push-merge.md`, not `commitPushMerge.md`).

## Adding a new rule

1. Decide where it goes:
   - **Inline in `AGENTS.md`** if it applies project-wide regardless of file (a new universal baseline).
   - **`rules/<name>.md`** if it applies only to a subset of files (use `globs` to scope).
   - **`rules/optional/<name>.md`** if it presumes a specific framework, language, or tool that not every project uses.
2. For files under `.agents/`, create them with the frontmatter above.
3. Add the file to the appropriate table in the root `AGENTS.md`.
4. If it's optional, list it under "Available optional rules" in `AGENTS.md`.

## Adding a new skill

1. Create `skills/<name>.md` with the skill frontmatter.
2. State the trigger phrase clearly so agents recognize when to invoke it.
3. Document constraints and failure modes — what to do if a step fails, what *not* to do.
4. Add it to the skills table in the root `AGENTS.md`.

## Nested overrides

A subdirectory in the consuming project may contain its own `AGENTS.md` to override or extend these rules for that area of the codebase. The nearest `AGENTS.md` wins; see precedence in the root `AGENTS.md`.
