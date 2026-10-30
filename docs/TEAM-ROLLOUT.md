# Team rollout guide

For a team sharing one workflow. Example numbers assume ~5–10 engineers; scale the rotations.

## Roles

| Role | Responsibility |
|---|---|
| Feature owner | Takes the ticket, runs kickoff, owns intent/spec/plan, merges the feature branch |
| Product owner | Accepts intent.md; resolves spec concerns with policy owners |
| Code owner reviewer | Human approval on every PR (rotate weekly; match tracks, e.g. iOS ↔ iOS) |
| Standards owner | Merges plugin changes, runs the monthly tune, owns evals (rotate quarterly) |
| Release approver | Sole holder of `RELEASE_APPROVAL` for production (rotate per release) |

## Branch model
```
main
 └─ feature/PROJ-123-chat-history        intent.md + spec.md + plan.<track>.md land here first
      ↑ task/PROJ-123-ios-el-store         task branches cut from the feature branch, one worktree each
      ↑ task/PROJ-123-android-jk-store
      ↑ task/PROJ-123-web-mr-ui
```
Task branches PR into the feature branch; the feature branch PRs into `main`. (Git can't hold both
`feature/X` and `feature/X/sub`, which is why task branches use their own `task/` prefix.)

## Rollout steps
1. Template and customize this repo (README → Quick start). Keep it private if your standards are internal.
2. Protect `main` and `stable` with CODEOWNERS review. Edit `docs/GOVERNANCE.md` for your team.
3. Pilot: one repo, two engineers, one week. Run `/craft:init`, ship one ticket end to end.
4. Fix what the pilot found in the CRAFT plugin (not in local copies), fast-forward `stable`, roll out to
   remaining repos with `/craft:init`.
5. Optional lock-in: an org admin applies `admin/managed-settings.json` through claude.ai
   Organization settings → Claude Code → Managed settings, or via MDM, so the plugin is required
   on every machine.
6. Connect your tracker in Claude Code (Jira/Atlassian, Linear, or `gh` for GitHub Issues) so
   kickoff reads tickets and links back.

## Cadence
- **Per ticket:** 30-minute kickoff, feature owner + product owner, ending with an accepted intent.
- **Daily:** each engineer steers 2–3 parallel sessions; clear the review queue before new work.
- **Weekly (30 min):** `/craft:retro` output, band breaches, top repeated mistakes.
- **Monthly (45 min):** standards tune per GOVERNANCE.md.

## Metrics (from Git, CI and the tracker)
Ticket → accepted intent · intent → spec · spec rework after plan · first-pass CI success for
agent PRs · time to first review · review comments resolved by Claude · eval pass rate per plugin
version · repeated-mistake count.
