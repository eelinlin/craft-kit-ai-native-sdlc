---
name: review
description: Stage 5 — fresh-context verify and review of this branch, fix chosen findings, open the PR.
disable-model-invocation: true
---
1. Use the `craft:verifier` agent; show its verdict.
2. Use the `craft:reviewer` agent on this branch against its parent branch (`task/<KEY>-…` →
   `feature/<KEY>-…`; `feature/` and `fix/` → the default branch); show findings grouped by severity.
3. Ask which findings to fix. Fix them, re-run `make verify`, and re-run the reviewer on the new
   diff until no Important findings remain.
4. Propose CLAUDE.md lines the reviewer suggested; add the ones the engineer approves.
5. Write the PR description from `${CLAUDE_PLUGIN_ROOT}/templates/artifacts/pr.md` and open it
   with `gh pr create --base <parent branch>`. Team: request the code owner for that track.
   Solo: leave it for your own review in a later sitting. Never merge it.
