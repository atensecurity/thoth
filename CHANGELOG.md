# Changelog

All notable changes to `thoth` and `thothctl` are documented in this file.

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
