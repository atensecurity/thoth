# Changelog

All notable changes to `thoth` and `thothctl` are documented in this file.

## 0.3.9 - 2026-10-23

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel. Linux and Windows artifacts are not included and remain at v0.3.6.

### Changed

- Trial and self-serve workspaces use `https://api.atensecurity.com` as their GovAPI by default.
  `https://govapi.trial.atensecurity.com` reaches the same service, and sessions saved for it keep
  working.
- `thothctl mcp config --trial` points clients at `https://mcp.atensecurity.com/<tenant>`, the
  dedicated MCP host. `https://govapi.trial.atensecurity.com/thoth/mcp/<tenant>` keeps working.

### Fixed

- A `thothctl auth login` session no longer stops working after about five minutes. The saved
  session now includes a refresh token, and commands renew the access token through GovAPI shortly
  before it expires. Each renewal re-checks the workspace membership and admin role. Sessions
  saved by 0.3.8 need one new login.

## 0.3.8 - 2026-10-19

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel. Linux and Windows artifacts are not included and remain at v0.3.6.

### Added

- `thothctl mcp config` generates client configuration for the tenant's Thoth
  configuration MCP endpoint, including Claude Code and Cursor. OAuth is the
  default; API-key configuration references an environment variable without
  embedding the credential.

- `thothctl tools list` shows tools discovered from your agents with their
  proposed effect classes, and `thothctl tools confirm` records an admin's
  confirmed classes. Only confirmed classes change decisions. `thoth tools`
  forwards to the same commands.
- `thothctl init --agent-id AGENT --profile PROFILE` gives an agent a governance
  profile (`safe-default`, `coding-agent`, `finance-operations` or
  `customer-support`), pinned at `--profile-version` (default `1.0.0`).
- The MCP proxy reports the tools an MCP server lists, including its
  `readOnlyHint`, `destructiveHint` and `openWorldHint` annotations, as
  advisory proposals. Annotations are claims made by the server, never
  authority.

### Fixed

- `thothctl auth login` works for trial and self-serve workspaces with no options: sign in in the
  browser, and GovAPI finds your workspace from the organization you signed in to. The workspace
  is saved to `~/.thoth/current-workspace.json`, so later commands no longer need `--tenant-id`.
  A 32-character workspace ID still works and selects the shared GovAPI host. GovAPI finds the
  WorkOS organization from the workspace instead of the email domain, and the admin check uses
  the workspace role GovAPI reports.

### Privacy

- The proxy removes schema `default`, `example`, `examples`, `const` and `enum`
  values before reporting tools, keeps parameters with those names, and
  percent-encodes the tenant ID. Set `THOTH_TOOL_INVENTORY=off` to disable
  reporting.

### Changed

- Added internal broker execution plumbing that is not enabled in this
  release and changes no runtime behaviour.

## 0.3.7 - 2026-09-12

Stable release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon
and Intel. This is the global latest release; Linux and Windows artifacts are
not included and remain at v0.3.6. This client release does not change the
platform readiness status.

### Security

- Updated the HTTP/2 stack from `h2` 0.4.13 in v0.3.6 to 0.4.19, fixing
  RUSTSEC-2026-0258 (unbounded queuing of empty DATA frames through `hyper`).
  The advisory is patched in h2 0.4.16 and later.

### Added

- Carried an action attestation ID through every governed tool call. The proxy
  reuses `action_attestation_id` from the request when supplied and otherwise
  generates one, sends it to the enforcer, and reports it on decision responses
  and on both the request and terminal telemetry events, so an attempt can be
  correlated end to end.
- Reported decision evidence on `ALLOW` and `BLOCK` responses, which previously
  carried none. `BLOCK`, `DEFER` and `STEP_UP` responses now include the
  enforcement trace ID, action attestation ID, authorization decision, reason,
  reason code, action classification and risk score when the enforcer supplies
  them.

### Fixed

- Stopped writing enforcer error response bodies and selected response headers
  into proxy logs when a call fails. A failure is now recorded as a reason code
  (`enforcer_transport_error`, `enforcer_http_error`, `enforcer_invalid_response`)
  with the HTTP status only, so response content cannot reach logs.
- Distinguished an enforcer response with no recognized decision from a genuine
  `BLOCK`. Both still fail closed, but the former is now recorded as
  `enforcer_invalid_response` rather than being indistinguishable from a policy
  denial in evidence.
- Preserved request-side correlation IDs on the terminal event when the enforcer
  is unreachable, returns an error status, or returns an undecodable body, so a
  failed call is still traceable to the attempt that caused it.
- Kept a locally escalated `STEP_UP` from exporting a receipt that the
  underlying `ALLOW` never carried.
- Distinguished an absent model risk score from one the enforcer explicitly
  reported as null, and stopped copying non-numeric risk payloads into decision
  evidence.
- Cleared stale request-side reason fields from terminal telemetry so a decision
  reason always describes that decision.

### Known limitations

- On Windows the proxy API key file (`~/.thoth/proxy_api_key.json`) is written
  with inherited ACLs. The owner-only permission handling that `thothctl`
  applies on macOS and Linux has no Windows equivalent yet, so treat that file
  as readable by any account with access to the user profile until it does.

### Changed

- Serialized the decision-evidence integration fixtures. Each spawns a proxy
  subprocess and a mock enforcer, and running them concurrently exhausted the
  proxy's bounded 5s HTTP timeout, so the proxy failed closed and the suite
  reported six failures unrelated to proxy behavior.


## 0.3.7-rc1 - 2026-09-11

Release candidate. Not a production release and not published to the stable
Homebrew or WinGet channels.

### Added

- Carried an action attestation ID through every governed tool call. The proxy
  reuses `action_attestation_id` from the request when supplied and otherwise
  generates one, sends it to the enforcer, and reports it on decision responses
  and on both the request and terminal telemetry events, so an attempt can be
  correlated end to end.
- Reported decision evidence on `ALLOW` and `BLOCK` responses, which previously
  carried none. `BLOCK`, `DEFER` and `STEP_UP` responses now include the
  enforcement trace ID, action attestation ID, authorization decision, reason,
  reason code, action classification and risk score when the enforcer supplies
  them.

### Fixed

- Stopped writing enforcer error response bodies and selected response headers
  into proxy logs when a call fails. A failure is now recorded as a reason code
  (`enforcer_transport_error`, `enforcer_http_error`, `enforcer_invalid_response`)
  with the HTTP status only, so response content cannot reach logs.
- Distinguished an enforcer response with no recognized decision from a genuine
  `BLOCK`. Both still fail closed, but the former is now recorded as
  `enforcer_invalid_response` rather than being indistinguishable from a policy
  denial in evidence.
- Preserved request-side correlation IDs on the terminal event when the enforcer
  is unreachable, returns an error status, or returns an undecodable body, so a
  failed call is still traceable to the attempt that caused it.
- Kept a locally escalated `STEP_UP` from exporting a receipt that the
  underlying `ALLOW` never carried.
- Distinguished an absent model risk score from one the enforcer explicitly
  reported as null, and stopped copying non-numeric risk payloads into decision
  evidence.
- Cleared stale request-side reason fields from terminal telemetry so a decision
  reason always describes that decision.

### Known limitations

- On Windows the proxy API key file (`~/.thoth/proxy_api_key.json`) is written
  with inherited ACLs. The owner-only permission handling that `thothctl`
  applies on macOS and Linux has no Windows equivalent yet, so treat that file
  as readable by any account with access to the user profile until it does.

### Changed

- Serialized the decision-evidence integration fixtures. Each spawns a proxy
  subprocess and a mock enforcer, and running them concurrently exhausted the
  proxy's bounded 5s HTTP timeout, so the proxy failed closed and the suite
  reported six failures unrelated to proxy behavior.

## 0.3.6 - 2026-07-09

### Fixed

- Emitted behavioral telemetry events from the Rust `thoth` proxy for local
  preflight outcomes (`BLOCK`, `DEFER`, `STEP_UP`) and forwarded execution
  outcomes so Claude Desktop/runtime decisions are ingested through
  `/v1/events/batch` and appear in governance feeds.

## 0.3.5 - 2026-06-10

### Added

- Added MCP vendor registry and catalog verification command surfaces in `thothctl`
  to align CLI capability with current control-plane governance APIs.

### Changed

- Updated release automation and public distribution flow for `thoth` and `thothctl`
  so production release tags drive Homebrew package publication from signed assets.

## 0.3.4 - 2026-05-22

### Fixed

- Corrected local preflight scope handling so `thoth` only enforces tool-name scopes,
  while ignoring non-tool permission scopes (for example `endpoint:checkin`) during
  tool matching.
- Added regression coverage for `tool_call:`-prefixed scope entries to prevent false
  denials in Claude Desktop `filesystem-safe` sessions.

## 0.3.3 - 2026-05-10

### Changed

- Promoted the Thoth binary line to `v0.3.3` for proxy/CLI release packaging.
- Updated public documentation references to the current stable binary line.

## 0.3.2 - 2026-05-10

### Added

- `thothctl billing artifacts` command for AIRS monthly report artifact access:
  - list recent monthly artifact rows with downloadable PDF/CSV links
  - fetch a specific month via `--year` + `--month`
  - optional JSON file output via `--output`

### Changed

- Updated `thothctl` manual pages to document AIRS report artifact workflows
  and command examples.

## 0.3.1 - 2026-05-09

### Changed

- Bumped the Thoth binary line to `v0.3.1`.
- Synced public docs/install references for `thoth` and `thothctl` to the current stable line.

## 0.3.0 - 2026-05-05

### Changed

- Promoted the Thoth binary line to `v0.3.0`.
- Aligned release metadata and published-artifact versioning for `thoth` and `thothctl`.
- Updated release process to consume versioned changelog entries for public release notes.
