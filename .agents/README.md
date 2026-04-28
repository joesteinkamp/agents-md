# `.agents/` — schema and conventions

This directory holds the rules and skills that AI agents consult while working in the project. The root `AGENTS.md` is the entry point and indexes everything here.

## Layout

```
.agents/
├── rules/
│   ├── *.md            # default rules — apply to every project that installs the kit
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
| Example      | `testing.md` — write behavior-focused tests       | `commit-push-merge.md` — commit, push, open PR, auto-merge  |

If you find yourself describing a multi-step procedure in a rule, it probably belongs in `skills/`. If you find yourself writing constraints inside a skill, those probably belong in `rules/`.

## File schema

Every file in `rules/` and `skills/` starts with YAML frontmatter, followed by Markdown.

### Rule frontmatter

```yaml
---
description: One-line summary of what this rule covers.
globs: ["**/*.ts", "src/**/*"]   # paths or patterns this rule applies to
alwaysApply: true                # true for default rules, false for optional/
---
```

- `description`: short, human-readable; surfaced in tool UIs.
- `globs`: array of paths or glob patterns. Use `["**/*"]` for project-wide rules.
- `alwaysApply`: `true` for default rules in `rules/`; `false` for files in `rules/optional/`.

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

1. Decide: default or optional?
   - Default if it applies regardless of stack (security, git, generic testing principles).
   - Optional if it presumes a specific framework, language, or tool.
2. Create the file in the right directory with the frontmatter above.
3. Add it to the appropriate table in the root `AGENTS.md`.
4. If it's optional, list it under "Available optional rules" in `AGENTS.md`.

## Adding a new skill

1. Create `skills/<name>.md` with the skill frontmatter.
2. State the trigger phrase clearly so agents recognize when to invoke it.
3. Document constraints and failure modes — what to do if a step fails, what *not* to do.
4. Add it to the skills table in the root `AGENTS.md`.

## Nested overrides

A subdirectory in the consuming project may contain its own `AGENTS.md` to override or extend these rules for that area of the codebase. The nearest `AGENTS.md` wins; see precedence in the root `AGENTS.md`.
