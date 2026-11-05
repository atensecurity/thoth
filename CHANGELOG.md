# Changelog

All notable changes to `thoth` and `thothctl` are documented in this file.

## 0.3.14 - 2026-10-29

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel, and of the Linux runtime for x86_64 and arm64, the first Linux release
since v0.3.6 (`install.sh` installs it). Windows artifacts are not included and
remain at v0.3.6.
Evidence pack commands need the server from production v0.6.18 or later
(deployed 29 October 2026); session isolation needs v0.6.14 or later.

### Added

- **Evidence packs.** `thothctl evidence pack build [--period-start RFC3339 --period-end RFC3339]`
  builds a signed evidence pack for a period of up to 31 days (the previous calendar month by
  default), in the background; `thothctl evidence pack list` shows its status; `thothctl evidence
  pack download --pack-id <id> [--output-dir DIR]` saves every part (paid plans, or a trial's
  read-only retention window), fetching each from its short-lived link without sending your Thoth
  credential to storage.
- **Offline verification.** `thothctl evidence verify --pack <part>...` checks every part of a pack
  with no network access: the part sequence and file digests, each manifest's signature, every
  decision's attestation and receipt signature over the exact bytes it covers, the event chain's
  hashes, signatures and continuity, links and counts. A key is trusted only for its published
  purpose, from the list built into `thothctl`, or from `--trusted-key PURPOSE=SHA256` (repeatable)
  instead. The summary says what verification shows and what it does not (that every agent action
  reached Thoth, or that any control or requirement is met). `--json` gives a machine-readable
  result.
- **Published signing keys.** `thothctl evidence trusted-keys [--json]` prints the decision-receipt
  and evidence-pack key fingerprints built into this release, as published at
  https://docs.atensecurity.com/signing-keys.json.
- **Session isolation.** `thothctl investigate isolate --session-id <id> [--quarantine-agent]
  --confirm` makes Thoth deny every action in one session until it is released, while the agent's
  other sessions continue; `--quarantine-agent` also quarantines the agent.
  `thothctl investigate release --session-id <id> --confirm` releases it and restores the session's
  earlier status; an agent quarantine stays until lifted with `thothctl agents quarantine lift`.

## 0.3.13 - 2026-10-28

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel. Linux and Windows artifacts are not included and remain at v0.3.6.
Built with Rust 1.99.1. Versions 0.3.13 to 0.3.16 were prepared in the
repository on 25 October but never published; this release contains all of
them. Some commands need the server from production v0.6.13 or later
(deployed 28 October 2026).

### Added

- **Policy rules.** `thothctl governance policies list|create|update|toggle|promote|decide|delete`
  manages policy rules in dev or prod. A rule created by someone who is not an org admin stays
  pending until an org admin approves it with `decide`; `delete` needs `--confirm`.
  `thothctl governance policies simulate --environment dev|prod --tool <name> --agent-id <agent>
  [--params JSON]` shows what Thoth would decide for one tool call, and which rules matched,
  without running it. A simulation changes nothing: no hold, approval request, quarantine,
  notification or record. `--agent-id` is required on self-serve and trial workspaces.
- **Exceptions.** `thothctl exceptions list|get|create|review`: request a policy exception for a
  blocked action (`--violation-id`, `--justification`, `--frequency`, `--data-sensitivity`), and
  review requests (`--decision approve|deny|request_changes|approve_with_modification`, with
  `--policy-change-file` for a modification). `thothctl exceptions artifacts list|get|apply`
  applies an approved exception's policy change as a policy bundle (`--format rego|cedar`,
  `--mode enforce|observe`) and ends its temporary override; the same policy is never applied
  twice, and applying needs a plan with policy bundles.
- **Held actions.** `thothctl approvals get --approval-id <id>` shows one held action, and
  `thothctl approvals resolve --approval-id <id> --decision approve|deny [--note TEXT]` approves or
  denies it. Repeating the same decision is harmless and a conflicting one is refused.
- **Agents and endpoints.** `thothctl agents quarantine set|lift --agent-id <id>` quarantines an
  agent or lifts the quarantine. `thothctl agents discovered list|promote|block|unblock` acts on
  agents Thoth has seen calling without a registration (`block` needs `--confirm`).
  `thothctl kill-switch [--env dev|staging|prod] --confirm` quarantines every registered agent and
  active endpoint and stops running sessions; `thothctl endpoints quarantine set|lift
  --endpoint-id <id>` is the way back. `thothctl fleets
  list|get|create|update|delete|deploy|pause|rollback` manages fleets (`delete` and `rollback` need
  `--confirm`), and `thothctl endpoints set-mode --endpoint-id <id> --mode enforce|observe|off`
  sets one or more endpoints' mode.
- **Tools.** `thothctl tools confirm --agent-id <id>` declares a tool for one agent; without it the
  declaration covers every agent.
- **People and sign-in.** `thothctl team` manages people as a signed-in admin: on self-serve and
  trial workspaces `team members list|remove|set-role`, `team invitations list|create|revoke` and
  `team requests list|approve|deny`; on dedicated workspaces `team org-members
  list|invite|remove|set-role`. Neither removes yourself or the last admin.
  `thothctl settings security get|set|remove` manages sign-in security (`--require-mfa`,
  `--session-timeout-minutes`, `--ip-allowlist`); `get` shows the address Thoth sees you
  connecting from, which an allowlist must include. `thothctl auth step-up` confirms a second
  factor in the browser ahead of time; the proof lasts about 15 minutes and is shared with the
  Terraform provider's `use_thothctl_session`.
- **Slack.** `thothctl slack status|channels|set-channel` and `thothctl slack reviewers
  list|candidates|set` choose the approvals channel and who approves (API keys cannot appoint
  reviewers). `thothctl support status|create|invite|resend` manages the Slack Connect support
  channel with Aten as a signed-in organization admin; writes need `--confirm` and send an
  idempotency key you can reuse with `--idempotency-key` to retry safely.
- **Settings.** `thothctl settings set` changes the shadow-agent policy, the webhook, the SIEM
  destination and PAM. Only the flags given change; secrets are read from files (`-` for stdin),
  never from arguments.
- **Reports and billing.** `thothctl reports generate [--start] [--end] [--wait]` generates a
  report (in the background unless `--wait`), and `thothctl reports compliance-risk [--from] [--to]
  [--scenarios-file]` reads compliance risk, with your own monetary scenarios reported separately
  and never totalled. `thothctl billing statements list|download <YYYY-MM>` gets a paid
  workspace's month-end statements.
- **Model artifacts.** `thothctl model-artifacts list|get|register|verify-provenance|screen|waive|activate`
  takes an artifact through Thoth's activation gate, as the `thoth_model_artifact` Terraform
  resource does. `waive` and `activate` need `--confirm`.

### Changed

- `thothctl reports list` prints a table (report ID, cadence, status, generated, period, denials);
  `--json` keeps the full snapshots.
- `thothctl agents observe-summary` names modified and deferred actions only when there are any.
- Tables print booleans as yes or no, and numbers, instead of `-`.
- `thothctl manual` and `thoth manual` print a reference generated from the commands themselves.

## 0.3.12 - 2026-10-24

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel. Linux and Windows artifacts are not included and remain at v0.3.6.

### Added

- `thothctl settings decision-stream get` shows which decisions Thoth sends to your SIEM and how
  delivery is going (last delivered, last failure, failures in the last 24 hours), and
  `thothctl settings decision-stream set --enabled true|false --decisions non_allow|all
  --allow-sample-rate <0-1>` changes it. Turning it on needs a SIEM destination and an admin with a
  recent second factor.
- `thothctl tools confirm` takes `--target-sensitivity public|internal|confidential|restricted` and
  `--acting-privilege standard|elevated|admin`, sent to your SIEM with each decision for the tool.
  Confirming a tool again without them keeps what was declared.
- `thothctl reports download <report-id> [--format pdf|csv] [--output FILE]` saves a completed
  runtime security report. Downloading is on paid plans, and in the read-only window after a trial
  ends.
- `thothctl agents mode get|set --agent-id <id> [--mode observe|enforce] [--high-risk hold|deny]`
  shows or changes an agent's mode, and `thothctl agents observe-summary --agent-id <id> [--days N]`
  shows what enforcing would have denied or held for an agent in observe.

## 0.3.11 - 2026-10-24

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel. Linux and Windows artifacts are not included and remain at v0.3.6.

### Added

- `thothctl settings data-handling get` shows what Thoth keeps of tool arguments, prompts and
  tool output for the workspace, and `thothctl settings data-handling set --tool-arguments
  store|hash|redact|drop --prompts store|hash|drop` changes it. Changing it needs an admin with a
  recent second factor, which a signed-in session confirms in the browser. The default is hashed
  arguments and no prompts.
- `thothctl decisions list` lists recorded enforcement decisions newest first, filtered by
  `--outcome`, `--agent-id`, `--tool`, `--reason-code`, `--rule-id`, `--since` and `--until`,
  with `--cursor` for the next page. `thothctl decisions export` downloads the same selection as
  CSV (at most 5,000 decisions; it says when more matched). Export needs an admin and, during a
  trial, a paid plan.

## 0.3.10 - 2026-10-23

Release of the macOS runtime (`thoth` and `thothctl`) for Apple Silicon and
Intel. Linux and Windows artifacts are not included and remain at v0.3.6.

### Fixed

- Commands that need a recent second factor, such as `thothctl api-keys create`, no longer fail
  with HTTP 403 for signed-in sessions. The command prints and opens a confirmation link; you
  confirm in the browser with your authenticator, and it continues. That session can then run
  such commands for 15 minutes without asking again (the proof is kept in
  `~/.thoth/step-up.json`, readable only by you, and works only with that session). Needs a
  GovAPI with browser step-up for the CLI.

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
