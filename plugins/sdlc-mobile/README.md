# CRAFT Kit — mobile pack

The mobile extension for CRAFT Kit adds:
- `mobile-standards` skill: testing rule (test-first for logic, view models and networking;
  screenshot checks against mocks for UI), Swift and Kotlin conventions, privacy, store-review risks
- `store-release` skill: App Store and Google Play release items for `/craft:ship`
- Hook: formats the edited Swift (swift-format / swiftformat) or Kotlin (ktlint) file
- `templates/Makefile`: Xcode + Gradle targets for `make build/test/lint/screens/verify`

Enable it next to the core plugin in a repo's `.claude/settings.json`:
`"enabledPlugins": { "craft@craft-kit": true, "craft-mobile@craft-kit": true }`.
Add `"Bash(xcrun simctl*)"` and `"Bash(./gradlew *)"` to `permissions.allow` there.
