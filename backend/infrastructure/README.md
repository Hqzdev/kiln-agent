# SQLite storage

SqliteUnitOfWork initializes schema 1 with PRAGMA user_version. Higher versions
are rejected. The parent directory must exist. Each operation opens and closes
its connection, enables foreign keys, sets a 5-second busy timeout and executes
BEGIN IMMEDIATE. This serializes writes across separate adapter instances.
Repository changes and outbox events commit together; exceptions roll both back.

Tables: projects, runs, specifications, tasks, task_dependencies, outbox.
Foreign keys protect references; UNIQUE(run_id, revision) protects revision
numbering. Records store JSON projections for mapping; identifiers and relations
also have explicit SQL columns and constraints. Outbox seq is assigned by SQLite
independently of event UUID and entityVersion. No dispatcher runs in a transaction.

StorageException distinguishes constraints, corrupt JSON/domain data, and
connection/SQL failures. Configure BLOT_DATABASE in the API composition root.
