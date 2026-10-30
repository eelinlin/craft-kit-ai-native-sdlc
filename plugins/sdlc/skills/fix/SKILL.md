---
name: fix
description: Stage 4 — fix a bug test-first with test files locked by a hook.
argument-hint: <JIRA-KEY or bug description>
disable-model-invocation: true
---
Bug: $ARGUMENTS

1. Reproduce the bug as a failing unit or view-model test. Run it and confirm it fails for the
   expected reason. Show the failure output.
2. When the engineer confirms, commit the test (`test(<KEY>): reproduce <bug>`), then run
   `mkdir -p .claude/state && touch .claude/state/fix-mode`.
3. Make the test pass by changing code only. Test files are now locked.
4. Run `make verify` and paste the output.
5. Ask the engineer to remove `.claude/state/fix-mode` (you may not).
6. Add an eval case for this bug in `evals/cases/` (see evals/README.md) so it can't regress.
