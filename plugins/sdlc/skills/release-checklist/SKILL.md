---
name: release-checklist
description: Generic release readiness checklist. Use whenever bumping versions, writing release notes, deploying to staging or production, or publishing a package.
---
# Release checklist (v1.0)
Report each item ✅/❌ with evidence. Stack packs add their own items (e.g. app store rules).

1. `make verify` green on the release commit; paste the output.
2. Eval pass rate at or above the previous release (`evals/history.log`).
3. Every merged change since the last tag links an `intent/<KEY>-*/` folder; list the keys.
4. Version bumped; CHANGELOG.md updated from the intents.
5. Config, feature flags and migrations reviewed for the target environment.
6. Privacy and data: anything newly collected or sent is listed in a spec and disclosed where required.
7. Rollback path named and rehearsed (revert, flag off, staged rollout halt, previous build).

Draft release notes in user language (≤4 lines). Production is the release approver's call; the
release gate blocks it otherwise.
