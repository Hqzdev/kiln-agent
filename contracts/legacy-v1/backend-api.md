# Initial Blot API (schemaVersion 1)

Domain response fields are defined by `fixtures/contracts/domain-*.json`. UUIDs
are case-insensitive strings. Dates use UTC ISO-8601 with Z and an optional
fractional part. Versions are nonnegative; specification revisions start at 1.

| Route | Request | Response |
| --- | --- | --- |
| POST /projects | name, repositoryPath | 201 Project |
| GET /projects/{id} | UUID | 200 Project |
| POST /runs | projectId, goal | 201 Run, DRAFT/version 0 |
| GET /runs/{id} | UUID | 200 Run |
| PATCH /runs/{id}/status | expectedVersion, status | 200 Run |
| POST /runs/{id}/specifications | content | 201 SpecificationRevision |
| GET /runs/{id}/specifications | UUID | 200 ordered revisions |
| POST /tasks | projectId, runId, title, acceptanceCriteria, dependencyIds | 201 Task |
| GET /runs/{id}/tasks | UUID | 200 tasks |
| POST /commands | Command envelope | 200 resulting entity |
| GET /health, /ready | none | 200 status UP |

Command envelope: schemaVersion=1, commandId, type, payload. Supported types:
project.create, run.create, run.status.change, specification.revision.create,
task.create. Their payloads are the public BlotAPI command types, except
run.create uses projectId at envelope level and goal in payload, preserving the
original fixture. Legacy envelope expectedVersion is optional and ignored;
status changes require expectedVersion in their payload.

commandId provides correlation, not retry deduplication. Clients must not
automatically retry mutations. Reading uses GET, starting uses status transitions
DRAFT→PLANNING→RUNNING, cancelling uses status CANCELLED. Updating a specification
appends an immutable revision. This slice supports creation and reading of tasks.

Errors always contain code, message, details (a string dictionary). Status codes:
400 validation; 404 not_found; 409 conflict/version_conflict/invalid_transition;
503 storage_unavailable; 500 internal. Internal exception details are not exposed.

Outbox events are stored atomically with state. seq is a positive decimal string;
runId is null for project.created. Supported event types and string payloads:
project.created (name), run.created (goal/status), run.status_changed (from/to),
specification.revision_created (revision), task.created (title). The adapter
assigns seq in SQLite; SSE delivery is outside this slice.

Unknown command types and statuses are rejected. Unknown event types are
preserved so consumers can skip them. Breaking field or discriminator changes
require a new schemaVersion. Additive optional fields may preserve version 1.
Required and optional fields are specified in the schemas and public types;
task dependencyIds may be empty, acceptanceCriteria may not be empty.

Java and Swift read the same fixtures. CI also passes a real Java HTTP response
to the public Swift decoder through a build artifact.

CI selects Xcode 26.0.1 explicitly, rather than the runner default; it is listed
in the [official runner image inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md#xcode).
