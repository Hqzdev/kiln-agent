# BlotAPI

Public Codable command values, Command envelope, ProjectEvent, APIError and
WireJSON. Dependencies are BlotDomain and Foundation. Use WireJSON.encoder()
and decoder() for Java interoperability; dates always include UTC.

The complete contract is in `../../contracts/backend-api.md`. Tests read golden
fixtures directly from `../../fixtures/contracts`.

Run `swift test --package-path packages/BlotAPI` from the repository root.
After Java check, set BLOT_HTTP_FIXTURES to the absolute `.build/http-fixtures`
directory to verify actual Java HTTP response decoding as well.
