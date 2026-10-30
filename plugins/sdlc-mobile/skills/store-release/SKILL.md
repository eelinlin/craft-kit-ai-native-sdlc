---
name: store-release
description: App Store and Google Play release items. Use with the core release-checklist whenever preparing TestFlight, Play internal/closed tracks, or a production store submission.
---
# Store release (v1.0)
Add these to the core release checklist, reporting ✅/❌ with evidence:

1. Version and build numbers bumped on each platform.
2. iOS privacy manifest, permission usage strings and Play data-safety form match the code and SDKs.
3. Screenshots in `artifacts/screens/` current for changed screens; store screenshots updated if
   the UI changed materially.
4. In-app purchases / subscriptions tested in sandbox; Restore Purchases present where required.
5. Review notes explain how to reach gated or paid features (demo account if needed).
6. Rollout plan: iOS phased release on; Android staged rollout % set; halt procedure written down.

Pre-release lanes (e.g. `fastlane ios beta`, `fastlane android internal`) run after the engineer
confirms. Production submission stays with the release approver (`RELEASE_APPROVAL`).
