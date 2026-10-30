# Changelog

## Unreleased

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
