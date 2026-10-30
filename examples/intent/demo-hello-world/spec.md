# Spec: hello-world endpoint
Ticket: DEMO-01 · From: intent.md (accepted) · Status: accepted

## Requirements
- R1: The service exposes `GET /hello`.
- R2: A successful request returns HTTP 200.
- R3: The response content type is JSON.
- R4: The response body is exactly shaped as `{"message":"Hello, world!"}`.
- R5: An automated test verifies the route, status, content type, and response body.

## User flow
Client → `GET /hello` → `200 OK` with a JSON greeting.

## Design
No UI. The endpoint returns a single, stable JSON object.

## Technical design
Implement one route using the service's existing routing conventions. No database, external API, authentication, or environment-specific configuration is required.

## Areas of concern
Keep the response contract intentionally small so this remains a beginner-friendly example.
