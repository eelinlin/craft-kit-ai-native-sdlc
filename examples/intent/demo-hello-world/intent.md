# Intent: hello-world endpoint
Ticket: DEMO-01 · Author: Example team · Status: accepted
Source: example

## Problem
A new service needs a minimal, predictable health-of-the-app greeting endpoint that demonstrates the team's delivery workflow.

## Proposed outcome
A client can request `GET /hello` and receive a small JSON response containing the greeting "Hello, world!".

## Affected users and systems
API clients and the example service.

## Constraints
Keep the example stack-neutral at the workflow level. Do not introduce authentication, persistence, user data, third-party integrations, location data, or vendor-specific services.

## Success looks like
- `GET /hello` returns HTTP 200.
- The response is valid JSON with a `message` field set to `Hello, world!`.
- Automated tests cover the successful response.

## Out of scope
Personalization, configuration, localization, and storage.

## Open questions
None for this minimal example.
