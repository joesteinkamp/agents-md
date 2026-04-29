# Behavioral evals

A minimal harness for measuring whether installing this kit changes how an
agent behaves. The static structure of `AGENTS.md` doesn't tell you that — only
running an agent against tasks does.

## How it works

For each task, `run.sh`:

1. Creates a fresh git repo in a tempdir.
2. Runs the task's `setup.sh` to lay down fixture files.
3. Optionally copies `AGENTS.md`, `CLAUDE.md`, and `.agents/` in (treatment).
4. Invokes an agent with the task's `prompt.md`.
5. Runs the task's `check.sh`, which prints one `PASS|FAIL\t<rule>\t<detail>`
   line per assertion.
6. Aggregates a control-vs-treatment scoreboard.

Each task is a directory under `tasks/` with three files:

| File         | Purpose                                                  |
| ------------ | -------------------------------------------------------- |
| `prompt.md`  | The user instruction the agent sees. Phrase it like a real dev task — don't tip the agent off that it's being tested. |
| `setup.sh`   | Runs in the empty sandbox repo; lays down fixture files. |
| `check.sh`   | Runs in the sandbox after the agent finishes; uses helpers from `lib/check.sh` to emit pass/fail lines. |

## Usage

```sh
# Run every task, both arms, with Claude Code as the agent.
evals/run.sh

# Just one task, treatment only.
evals/run.sh --mode=treatment branch-naming

# Bring your own agent. {prompt_file} is substituted with the prompt path.
AGENT_CMD='cursor-agent --prompt-file {prompt_file}' evals/run.sh

# Drive the agent by hand — the runner pauses so you can do the work yourself.
AGENT_CMD=manual evals/run.sh secret-handling
```

The default `AGENT_CMD` invokes `claude -p` in headless mode with permissions
bypassed. Real runs cost API spend; the manual mode is free and useful for
sanity-checking new tasks.

## Reading the scoreboard

```
Task                      Control     Treatment
branch-naming             1/4         4/4
secret-handling           1/4         4/4
commit-subject            2/5         5/5
TOTAL                     4/13        13/13
```

The signal you're looking for is `treatment > control`. If the kit makes no
difference, both columns will look the same and the kit isn't paying for its
context budget. If control already passes, the rule is something the model
does anyway and doesn't need to be in `AGENTS.md`.

## Adding a task

1. Pick one rule from `AGENTS.md` that should change observable behavior.
2. Write a prompt that creates the *opportunity* to violate it without
   mentioning the rule.
3. Write checks that pass only when the rule is followed. Avoid checks that
   pass for the wrong reason (e.g. "branch is not main" passes if the agent
   does nothing — pair it with "feature was implemented").
4. Run `AGENT_CMD=manual evals/run.sh <task>` and play both sides yourself to
   make sure the checks fire correctly.

## Limits

- Three tasks is a smoke test, not a benchmark. Aim for 15–25 to get past
  per-run noise.
- Each task is one sample. To distinguish a real effect from variance, run
  each arm N times (loop the runner) and compare distributions.
- The harness only catches behaviors observable in the resulting git state.
  Things like "the agent asked a clarifying question" need a different setup.
