---
name: retro
description: Stage 6 — weekly loop: band check, findings to intents, repeated mistakes to CLAUDE.md or the plugin.
disable-model-invocation: true
---
1. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/check-bands.sh"` and show the result per metric.
2. 2σ breach: diagnose read-only; explain the likely cause with evidence.
3. 3σ breach: draft a new intent (Source: band-breach) with anomaly, evidence, proposed outcome and
   open questions, in a folder named `intent/TRIAGE-<date>-<slug>/`. A human files the tracker ticket
   and renames it. Don't change code.
4. Read `git log --since="1 week ago"`, merged PR review comments, and `.claude/state/gates.log`.
   List mistakes Claude repeated and gates that blocked often.
5. Recommend: CLAUDE.md line (one repo) or plugin change (two or more repos — see GOVERNANCE.md).
6. Ask the team to triage each finding: fix now, schedule, or dismiss.
