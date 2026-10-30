---
name: ship
description: Stage 5 — prepare a pre-release (beta, staging) or a production release for the release approver.
argument-hint: beta | release
disable-model-invocation: true
---
Use the release-checklist skill, plus any stack release skill available (for example
`craft-mobile:store-release`), for: $ARGUMENTS.

- **beta:** run the checklist, then the repo's pre-release command from CLAUDE.md (staging deploy,
  TestFlight, Play internal track…). Permission settings will ask the engineer to confirm.
- **release:** run the checklist, draft release notes, and stop. Production is blocked by the
  release gate until the release approver runs it with `RELEASE_APPROVAL` set.
