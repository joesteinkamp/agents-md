# Behavioral evals

> When a coding agent is given the AGENTS.md kit as context, do its outputs
> actually honor the rules — and *more* than they would with a flatter rule
> list, or with no context at all?

This is the question daily-driving the kit cannot answer. Static lints can
tell you `AGENTS.md` is well-formed; only running an agent against tasks can
tell you the format is doing work.

This package is a **methodology sketch**. It runs end-to-end against
deterministic mock agents so the harness can be self-tested before any model
API spend, then provides a clear seam for plugging in a real model.

## What it measures

For each `(task × format × agent × rep)` cell the harness:

1. Creates a fresh sandbox git repo and runs the task's `setup.sh`.
2. Installs context in one of three formats (the A/B/C):
   - **`agentsmd`** — the full kit: `AGENTS.md` + `CLAUDE.md` + `.agents/`. The treatment.
   - **`flat`** — just the always-on rules as a single `RULES.md`, no four-file scaffolding (control: "is the structure doing work, or any rules?").
   - **`none`** — empty (control: "would the agent do this anyway?").
3. Records `BASELINE_REF`, then invokes the agent against `prompt.md`.
4. Runs `check.sh` in the sandbox, scoring rule adherence by counting
   `PASS` / `FAIL` lines.

Aggregating across cells gives a pass-rate per format. **The hypothesis is
that `agentsmd` ≫ `none`, and ≥ `flat`.** If it isn't, the four-file
structure isn't earning its keep over a flat rule list — which is the only
thing daily-driving cannot tell you.

## What it does not measure (yet)

- **Conversational behavior** — only end-state in the git repo. Things like
  "the agent asked a clarifying question first" need a different setup.
- **Realistic prompts.** Tasks are short and synthetic. Production prompts
  have ambient context that may interact with the rules in ways we don't see.
- **Cross-model.** Built-in support is for Claude (`claude -p`) and the mock
  agents. Cursor / Copilot / Codex would each need a small adapter shim.

## Anatomy

```
evals/
├── run.sh                  # the runner
├── lib/
│   ├── check.sh            # assertion helpers used by check.sh scripts
│   └── format.sh           # builds context for a given format
├── agents/
│   ├── mock-instruction-follower.sh   # passes when rules are visible
│   └── mock-chaotic.sh                # ignores rules, fails everything
└── tasks/
    ├── branch-naming/      # one rule from AGENTS.md per task
    ├── secret-handling/
    └── commit-subject/
```

Each task is `prompt.md` (the instruction the agent sees), `setup.sh` (lays
down fixture files), and `check.sh` (emits one `PASS|FAIL\t<rule>\t<detail>`
line per assertion).

## How to run

```sh
# All tasks × all formats × both mocks, one rep each.
evals/run.sh

# Just one task, just the treatment, one mock.
evals/run.sh --format=agentsmd --agent=mock-instruction-follower commit-subject

# Three reps per cell, JSON report for later analysis.
evals/run.sh --reps=3 --out=reports/2026-05-02.json

# Run against the real model. Costs API spend.
evals/run.sh --agent=claude --reps=5
```

## Built-in agents

- **`mock-instruction-follower`** — checks whether any rules file is visible
  in the sandbox. If yes, performs the task in a rule-following way (named
  branch, env-based credentials, imperative commit subject). If no, falls
  back to default sloppy behavior. **This is the harness self-test:** with
  this agent, `agentsmd` and `flat` should score high, `none` lower. If
  they don't, the scorer is broken.
- **`mock-chaotic`** — ignores context and does the wrong thing every time
  (commits to main, hardcodes secrets, sloppy commit subjects). Should
  score near zero on every format. Sanity check that the scorer actually
  penalizes wrong outputs.
- **`claude`** — invokes `claude -p ... --permission-mode bypassPermissions`.
  This is the real measurement; the mocks are the harness self-test.

## Reading the scoreboard

```
Task / Agent                                agentsmd      flat          none
branch-naming / mock-instruction-follower   4/4           4/4           2/4
branch-naming / mock-chaotic                2/4           2/4           2/4
...
TOTAL by format                             20/28         20/28         14/28
```

Look for two signals:

1. **`agentsmd` > `none`** — the kit is doing *something*.
2. **`agentsmd` > `flat`** — the *structure* is doing something beyond just
   making the rules visible. If they're equal, a flat rule list is just as
   good and the four-file scaffolding isn't paying for its complexity.

The mock agents will not separate `agentsmd` from `flat` — they only check
"any rules visible." That separation is what the real-model run is for.

## Output shape

The `--out PATH` flag writes a JSON report:

```json
{
  "startedAt": "2026-05-02T12:00:00Z",
  "runs": [
    {
      "task": "commit-subject",
      "format": "agentsmd",
      "agent": "mock-instruction-follower",
      "rep": 1,
      "passed": 6,
      "total": 6,
      "assertions": [
        { "status": "PASS", "name": "agent made a commit", "detail": "" },
        ...
      ]
    }
  ]
}
```

Diff `runs` across reports to detect regressions in the kit itself (e.g. a
spec change that makes agents *less* likely to honor rules).

## Adding a task

1. Pick one rule from `AGENTS.md` that should change observable behavior.
2. Write a `prompt.md` that creates the *opportunity* to violate it without
   mentioning the rule.
3. Write `setup.sh` to create the starting state.
4. Write `check.sh` using helpers from `lib/check.sh`. Pair every "absence"
   check with a "feature implemented" check so a no-op agent fails cleanly.
5. Calibrate by running both mocks against it — the rule-follower should
   pass, the chaotic agent should fail.

## Limits

- Three tasks × two mocks is a smoke test, not a benchmark. Aim for 15–25
  tasks before trusting totals.
- One run per cell is noisy. Use `--reps=N` (5–10) and compare distributions.
- The mocks only differentiate "any rules / no rules." They can't tell you
  whether `agentsmd` beats `flat` — only a real model can.
