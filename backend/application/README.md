# Application module

`BlotApplicationService` is the application boundary for project, run, specification revision, and task use cases. It accepts typed command records and returns `ApplicationResult<T>` with either a value or a typed `ApplicationError`. It depends on `core` and Java standard-library types only; HTTP request/response DTOs belong in `api`.

## Transaction and event contract

Each use case runs inside `BlotUnitOfWork.transact`. An implementation must provide isolation that prevents lost run updates and duplicate specification revision numbers. Repository changes and `appendEvent` must commit atomically. Events are durable outbox records; dispatch to clients happens after commit. If the operation throws, implementations must roll back all entity and outbox writes.

The application writes schema-versioned event drafts. The infrastructure adapter assigns the monotonic `seq` when persisting the draft, then maps it to the envelope in `contracts/project-event.schema.json`. `runId` is null for project-level events. The API layer maps its transport commands to the application command records and translates `ApplicationError` into the documented HTTP response.

## Implemented use cases

- Create and read a project.
- Create and read a run; change run status with an expected-version check.
- Append an immutable specification revision and read the ordered history.
- Create and list tasks, validating project/run ownership and all task dependencies.

Run status transitions are deliberately enumerated in `RunTransitions`; terminal statuses cannot transition further. Persistence adapters and transport handlers are not part of this module.
