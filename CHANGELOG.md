# Changelog

## Unreleased

- craft 2.0.2: add the artifact templates (`templates/artifacts/intent.md`, `spec.md`, `plan.md`,
  `pr.md`) that `/craft:kickoff`, `/craft:spec`, `/craft:plan`, `/craft:review` and artifact-standards
  use. They were referenced but never shipped: `.gitignore`'s `artifacts/` rule (meant for build
  output) matched `templates/artifacts/` too. The rule is now anchored to the repo root.
- craft 2.0.2: the gates refuse the actions they check when `jq` is missing, instead of allowing
  everything.
- `/craft:init` CI workflows (Claude review, agent evals) only run `gh auth setup-git` when
  `PLUGIN_READ_TOKEN` is set, so they no longer fail for public marketplaces.
- Templates name the `craft` plugin instead of the old `sdlc` plugin.
- Contract tests check that every `${CLAUDE_PLUGIN_ROOT}/…` file a skill names ships, that the PR
  template copies match, and that workflow auth steps are guarded; the summary line no longer says
  "passed" when a check failed.

- The repository moved to `eelinlin/craft-kit-ai-native-sdlc`: install with
  `/plugin marketplace add eelinlin/craft-kit-ai-native-sdlc`. The marketplace name stays `craft-kit`,
  so `craft@craft-kit` and the uninstall commands are unchanged. Contract tests now check that the
  manifest repository matches the git remote, so a GitHub rename fails CI until the docs follow.
- Rebrand to CRAFT Kit: the repository is now `eelinlin/craft-kit` and the marketplace is `craft-kit`,
  so plugins install as `craft@craft-kit` and `craft-mobile@craft-kit`.
- Fix install, uninstall and managed-settings references that pointed at a non-existent
  `eelinlin/ai-native-sdlc-kit` repository.
- Fix the `/craft:init` settings template, which enabled a non-existent `sdlc` plugin instead of `craft`.
- craft 2.0.1: close release-gate bypasses (`git push` with no refspec or `HEAD` while on a protected
  branch, `+main`, `refs/heads/main`, `git -C <dir> push`).
- craft 2.0.1: the plan-before-code gate now sees code committed with `git commit -a` / `--all`.
- craft 2.0.1: the `/craft:init` config gates `task/` branches, matching the documented default.
- craft 2.0.1: remove the core PostToolUse hook that ran a non-existent `format.sh` after every edit
  (formatting lives in stack packs such as `craft-mobile`).
- craft 2.0.1: hook messages and templates name `/craft:` commands instead of the old `/sdlc:` ones.
- `check-bands.sh` no longer reads the CSV header row as a 0 data point, which raised false 3sigma
  breaches on short histories.
- `customize.sh` now works on macOS (its `sed \b` renames silently did nothing there).
- Tests: new `tests/test-bands.sh` and `tests/test-customize.sh`; contract tests now check that hook
  scripts exist, plugin and repo references match the marketplace, and `/craft:` commands exist.

## 2.0.0 — 2026-10-29

- Establish CRAFT as the workflow identity and `/craft:` command namespace.
- Ship the stack-neutral `craft` plugin and optional `craft-mobile` extension.
- Standardize the lifecycle from intent through planning, implementation, verification, review, release and maintenance.
- Add repository templates, engineering guardrails, review agents, customization tooling and automated validation.
