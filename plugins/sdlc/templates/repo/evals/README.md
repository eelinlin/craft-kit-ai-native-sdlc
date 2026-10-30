# Agent evals

Regression tests for your *agent setup* (CLAUDE.md, skills, hooks, model). Run `make evals`
whenever you change any of those, or switch models, and before each release.

Each case in `cases/` is a JSON file:
```json
{ "id": "0001-export-keeps-resolution",
  "prompt": "Add a unit test proving export keeps the original pixel size, then make it pass.",
  "checks": ["make test", "make lint"],
  "must_not_touch": ["Tests/Fixtures/"] }
```
`run.sh` runs each prompt headless in a throwaway worktree, then runs every check. A case passes
when all checks exit 0 and no `must_not_touch` path changed.

Grow the suite to 10–20 cases from real tasks. Every shipped bug fix adds one (`/craft:fix` step 6).
Drop cases that every model now passes trivially; they stop telling you anything.
