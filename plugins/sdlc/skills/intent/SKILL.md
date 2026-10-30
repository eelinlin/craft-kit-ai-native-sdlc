---
name: intent
description: Stage 1 — brainstorm a ticket into an accepted intent.md with the product owner.
argument-hint: <JIRA-KEY>
disable-model-invocation: true
---
Use the artifact-standards skill. Open `intent/$ARGUMENTS-*/intent.md`.

1. Interview like an analyst, one or two questions at a time: the problem, who is affected, what
   better looks like, constraints (privacy, platform, performance, legal, scope), how success is observed,
   what's out of scope. Stop when the idea is concrete.
2. Rewrite intent.md to the template. Keep the originator's words; no implementation detail.
3. Show it. Apply corrections. Only when the product owner says it's accepted, set
   `Status: accepted`, add `Accepted-by: <name> <date>`, and commit `intent($ARGUMENTS): accepted`.
4. Next step: `/craft:spec $ARGUMENTS`.
