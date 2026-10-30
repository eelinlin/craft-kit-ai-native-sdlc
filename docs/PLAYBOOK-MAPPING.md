# Playbook mapping

How each lesson of Anthropic's [AI-native SDLC playbook](https://academy.claude.com/courses/ai-native-sdlc-playbook)
is implemented here. Lesson summaries are paraphrased; read the course for the full guidance.

| Stage | Playbook practice | Implemented by |
|---|---|---|
| 1 Plan | Capture ideas as a short, version-controlled `intent.md` the product owner accepts | `skills/kickoff`, `skills/intent`, `templates/artifacts/intent.md`, `intent/` folder |
| 2 Design | Turn intent into a requirements + design spec in one session, constrained by policy skills, with flagged concerns | `skills/spec`, `templates/artifacts/spec.md`, standards skills (e.g. `craft-mobile:mobile-standards`) |
| 3 Build | Start in plan mode; commit the approved `plan.md`; keep it in sync with the code | `skills/plan`, `templates/artifacts/plan.md`, `require-artifacts.sh` hook |
| 3 Build | A short `CLAUDE.md`; add a line when Claude repeats a mistake | `templates/repo/CLAUDE.md`, `skills/retro`, reviewer agent proposals |
| 3 Build | Skills as institutional knowledge, backed by hooks where a rule must always hold | `skills/artifact-standards`, stack-pack skills, `docs/GOVERNANCE.md` |
| 3 Build | Parallel sessions in worktrees; repeated jobs as subagents | `[P]` tasks + `task/` branches in plans; `agents/verifier`, `reviewer`, `simplifier`, `researcher` |
| 3 Build | Build-time hooks: protected paths, formatting, secrets | `protect-paths.sh`, `craft-mobile` format hook |
| 4 Test | Give Claude a one-command feedback loop; failing test first for bugs; protect the test | `make verify`, `skills/fix`, `protect-tests.sh`, output style Evidence block |
| 4 Test | Continuous evals when agent configuration changes | `templates/repo/evals/`, `agent-evals.yml` |
| 5 Deploy | AI in the PR review loop with a written REVIEW.md; humans approve | `skills/review`, `templates/repo/REVIEW.md`, `claude-review.yml` |
| 5 Deploy | Hooks as approval gates; managed settings for non-negotiables | `release-gate.sh`, `admin/managed-settings.json` |
| 5 Deploy | CI/CD: agent acts up to the production gate, never past it | `skills/ship`, `release-checklist`, `RELEASE_APPROVAL` gate |
| 6 Maintain | Deterministic control bands trigger diagnosis and new `intent.md` files | `templates/repo/ops/bands.yaml`, `scripts/check-bands.sh`, `skills/retro` |

## Deliberate adaptations
- **Solo use.** The playbook assumes separate people per role. Here "another person" can be
  another context: a fresh reviewer agent, a later sitting, or a hook. See [SOLO.md](SOLO.md).
- **Tracker linkage.** The playbook offers repo-as-truth, tracker-as-truth, or linkage. This
  starter defaults to linkage: the tracker holds status, the repo holds intent/spec/plan/code.
- **Tracks.** One spec, one plan per track (ios, android, web, api) so multi-platform teams share
  requirements but plan independently.
