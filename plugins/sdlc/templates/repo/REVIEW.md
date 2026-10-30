# Review instructions

## Passes
Run three passes and tag each finding with its pass:
- **Bugs:** logic errors, edge cases, concurrency and lifecycle issues, leaks, regressions,
  behavior drift between tracks
- **Security & privacy:** secrets, PII or user content in logs/analytics, injection, auth gaps,
  data collected or sent that spec.md doesn't list, unsafe storage
- **Compliance:** diff matches intent/<KEY>-slug/spec.md and plan.<track>.md; deviations are
  written back to the plan; tests-first for logic, state and networking; screenshots for UI
  changes; naming per the artifact-standards skill

## Severity
- **Important:** would break behavior, crash, lose or leak data, breach a standard, or fail an
  external review (security, store, compliance).
- **Nit:** style, naming, small readability issues.

## Cap the nits
At most five nits per review; summarize the rest as a count.

## Do not report
Generated files, anything linters already enforce, lockfile and project-file noise.

## Feedback loop
If a finding repeats a previous review's finding, propose a CLAUDE.md line (or a plugin change if
it repeats across repos).
