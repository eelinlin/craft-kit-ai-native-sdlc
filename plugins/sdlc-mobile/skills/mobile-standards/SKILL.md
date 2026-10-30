---
name: mobile-standards
description: The iOS and Android engineering, testing, privacy and store-review standards. Use when writing a spec or plan, writing or changing Swift/SwiftUI or Kotlin/Compose code, adding permissions, SDKs, analytics, or networking.
---
# Mobile standards (v1.0 — edit to match your team; see docs/CUSTOMIZING.md)

## Testing
1. Test-first for logic, view models and networking: write tests from intent/spec, commit them,
   then generate code.
2. Mobile UI: SwiftUI previews / Compose previews plus screenshot checks against `mocks/` and the
   intent, instead of forcing tests first.
3. Never skip, disable or delete a failing test to get green.

## iOS
4. Swift 6 strict concurrency; SwiftUI; view models `@Observable @MainActor`.
5. No force unwraps outside tests. No new third-party dependency without a plan line saying why.

## Android
6. Kotlin, Jetpack Compose; ViewModel + StateFlow; coroutines on injected dispatchers.
7. No `!!` outside tests. Same dependency rule as iOS.

## Both platforms
8. Feature parity: user-visible behavior defined in spec.md must match unless Platform notes say why.
9. Every screen defines empty, loading, error and success states; supports dark mode, dynamic text
   size and screen readers.
10. Networking: timeouts, retries with backoff, and offline/error states for every call; no
    blocking the main thread.

## Privacy and data
11. No PII, message content or tokens in logs, analytics or crash reports.
12. Every permission has a specific, user-benefit usage string; request it in context, not at launch.
13. Keep the iOS privacy manifest and the Play data-safety form in sync with any SDK or data change.
14. Analytics events must be listed in spec.md; nothing else gets sent.

## Store review risks to flag in specs
Hidden or misleading features, missing permission strings, account creation without deletion,
paywalls that block reviewers, private APIs, and AI features without content reporting.
