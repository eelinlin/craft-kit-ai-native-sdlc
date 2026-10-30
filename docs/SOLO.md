# Solo developer guide

Everything works for one person. The rule that matters most: **the session that wrote the code
never approves it**. Without teammates, separate the roles in time and context instead.

| Role | Solo stand-in |
|---|---|
| Product owner | You, at kickoff. Accept the intent in a separate sitting from writing it. |
| Policy owners | Your standards skills; change them by commit like code. |
| Engineers | Claude Code sessions, one worktree per `[P]` task. |
| Second reviewer | `craft:reviewer` agent (fresh context, never saw the work). |
| QA | `make verify` + `craft:verifier` + evals. |
| Release manager | You, via `RELEASE_APPROVAL`. |
| On-call | A weekly `/craft:retro`, or a scheduled task that runs it. |

## Setup
In `/craft:init`, choose **solo** and **no tracker**. That sets:
```json
{ "ticketPattern": "[0-9]{4}", "workBranchPrefixes": ["feature", "fix", "task"], "protectedBranches": ["main"] }
```
Changes are then `intent/0001-local-editor/`, branches `feature/0001-local-editor`.
Delete `.github/workflows/claude-review.yml` if you don't want CI review.

## Weekly rhythm
- **Mon:** `/craft:retro`, pick one or two intents.
- **Tue–Thu:** spec → plan → two parallel sessions; review in the evening, not right after writing.
- **Fri:** beta build, `make evals`, add the week's repeated mistakes to CLAUDE.md.
