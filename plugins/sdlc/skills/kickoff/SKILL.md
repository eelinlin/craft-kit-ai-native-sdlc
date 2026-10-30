---
name: kickoff
description: Start work on a ticket — create the work branch and the intent folder seeded from the ticket.
argument-hint: <TICKET-KEY>
disable-model-invocation: true
---
# Kickoff for $ARGUMENTS

1. Read `.claude/sdlc.json` (if present) for `workBranchPrefixes` and `artifactDir`; defaults are
   `feature` and `intent`.
2. Get the ticket. If a tracker tool is available (Jira, Linear, GitHub Issues via `gh issue view`,
   or another MCP connector), read $ARGUMENTS: summary, description, acceptance criteria, links.
   Otherwise ask for the ticket text. Solo with no tracker: treat $ARGUMENTS as the idea and use the
   next free 4-digit number as the key if the repo's `ticketPattern` allows it.
3. Make a slug of 2–4 lowercase words from the summary.
4. From an up-to-date default branch, create `feature/<KEY>-<slug>`.
5. Create `intent/<KEY>-<slug>/` with `intent.md` from
   `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/intent.md` (Status: draft), filled from the ticket in
   the ticket author's words, plus `mocks/.gitkeep`.
6. Commit: `intent(<KEY>): seed from ticket`.
7. If a tracker tool is available, comment on the ticket with the branch and artifact path.
8. Next step: `/craft:intent <KEY>` to finish the intent with the product owner.
