---
name: artifact-standards
description: Rules for SDLC artifacts — intent.md, spec.md, plan.<track>.md, PR descriptions, commit messages and branch names. Use whenever writing or editing any of these.
---
# Artifact standards (v1.0)

## Names (prefixes, key format and folder are configurable in `.claude/sdlc.json`)
- Branch: `feature/<KEY>-<slug>`; task branch `task/<KEY>-<track>-<initials>-<task>`, cut from and merged back into the feature branch
  (Git cannot hold both `feature/X` and `feature/X/sub`, so task branches use their own prefix);
  bugs `fix/<KEY>-<slug>`; non-feature work `chore/<slug>` or `docs/<slug>`.
- Folder: `intent/<KEY>-<slug>/` with `intent.md`, `spec.md`, one `plan.<track>.md` per track, `mocks/`.
- Commits: `<type>(<KEY>): <summary>`; type ∈ intent, spec, plan, feat, fix, test, refactor, chore, docs.

## Templates (use exactly; don't add or drop sections)
- intent: `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/intent.md`
- spec: `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/spec.md`
- plan: `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/plan.md`
- PR: `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/pr.md`

## Writing rules
- intent.md: under one page, the originator's words, no implementation. Status starts `draft`;
  only the product owner (solo: you, in a later sitting) sets `accepted`.
- spec.md: requirements numbered R1…, each testable. Areas of concern always present (write
  "None found" only after checking every standards skill).
- plan: every task names files, tests-first list and proof. `[P]` marks parallelizable tasks.
- Every artifact header carries the ticket key. The tracker holds status; the repo holds content.
- When code departs from the plan, update the plan in the same commit.
