---
name: spec
description: Stage 2 — turn an accepted intent into spec.md with flagged concerns, constrained by the repo's standards skills.
argument-hint: <TICKET-KEY>
disable-model-invocation: true
---
Read `intent/$ARGUMENTS-*/intent.md`. Stop if it is not `Status: accepted`.

Produce a requirements and design spec for integrating it into this codebase, using
`${CLAUDE_PLUGIN_ROOT}/templates/artifacts/spec.md`. Apply every standards skill available (for
example `craft-mobile:mobile-standards`, or your own brand, security, UX or API skills) and record
each skill and version used in the header. Requirements are track-neutral; put differences between
tracks (e.g. iOS vs Android, web vs API) under Track notes.

Describe clearly any areas of concern, especially where the intent contradicts a standard, where
standards contradict each other, or where tracks can't behave the same. Answer the intent's open
questions or carry them forward.

Write `spec.md` in the same folder. Walk the engineer and product owner through each concern and
record each resolution. When none remain open, commit `spec($ARGUMENTS): accepted`. For UI work,
remind them to add design exports to `mocks/`; these become the screenshot targets.
