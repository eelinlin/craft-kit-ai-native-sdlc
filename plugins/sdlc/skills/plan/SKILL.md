---
name: plan
description: Stage 3 — in plan mode, write plan.<track>.md from intent + spec. Run in plan mode.
argument-hint: <TICKET-KEY> <track e.g. ios | android | web | api | all>
disable-model-invocation: true
---
Arguments: $ARGUMENTS (ticket key, then track).

Read `intent/<KEY>-*/intent.md`, `spec.md`, any existing `plan.*.md` for other tracks, and this
repo's CLAUDE.md. Produce a plan using `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/plan.md`: files
that change, order of work, tests written first (logic, state, data, networking), visual proof for
UI against `mocks/`, risks, and proof of done.

Split the work into tasks that touch different files and mark them `[P]` with a suggested task
branch `task/<KEY>-<track>-<initials>-<task>` (cut from `feature/<KEY>-<slug>`, PR back into it) so they
can run in parallel worktrees.
Keep tasks that share files in a single task.

Interrogate the plan with the engineer: what could this break, which step is riskiest, what options
were rejected, does it agree with the other tracks' plans where behavior must match? Iterate until
someone who never saw this conversation could implement it.

When approved, write `plan.<track>.md`, commit `plan(<KEY>): <track>`, and list each `[P]` task with
its `claude --worktree <name>` command.
