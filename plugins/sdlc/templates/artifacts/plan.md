# Plan (<track>): <title>
Ticket: <KEY> · From: spec.md (accepted) · Owner: <name>

<!-- Written so someone who never saw the planning conversation could implement it.
     When the code departs from this plan, update the plan in the same commit. -->

## Files that change
- `<path>` — add | change | delete — why

## Tasks
<!-- In order. Tasks that touch different files can run in parallel: mark them [P] and give each a
     task branch cut from feature/<KEY>-<slug> and a worktree command. Tasks that share files stay one task. -->
1.
2. [P] <task> — branch `task/<KEY>-<track>-<initials>-<task>` — `claude --worktree task-<KEY>-<track>-<task>`

## Tests first
<!-- Logic, state, data and networking tests written before the code they cover. -->
-

## UI proof
<!-- Screenshots compared against mocks/, or "None (no UI)". -->

## Risks
<!-- What this could break and the riskiest step. -->

## Rejected options

## Proof of done
- `make verify` passes.
-
