# Plan (api): hello-world endpoint
Ticket: DEMO-01 · From: spec.md (accepted) · Owner: Example team

## Files that change
- API route module — add — expose `GET /hello`
- API route tests — add — verify response contract

## Tasks
1. Add the `GET /hello` route returning `{"message":"Hello, world!"}`.
2. Add a focused test for status, content type, and response body.
3. Run the repository's standard verification command.

## Tests first
- `test_hello_returns_200`
- `test_hello_returns_json_greeting`

## UI proof
None (API-only example).

## Risks
Avoid adding dependencies or unrelated application architecture for a one-route example.

## Proof of done
- Both focused tests pass.
- The repository's standard verification command passes.
