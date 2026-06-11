# thoth

Thoth MCP governance runtime + headless control-plane CLI.
Governs MCP tool calls through the Moses enforcement pipeline and supports
GitOps-first tenant bootstrap via `thothctl`.

## Install

**macOS (Homebrew)**

```bash
brew tap atensecurity/tap
brew install thoth
thoth --version
thothctl --version
```

**macOS (Notarized PKG)**

```bash
curl -LO https://github.com/atensecurity/thoth/releases/download/v<VERSION>/thoth-macos-universal.pkg
sudo installer -pkg thoth-macos-universal.pkg -target /
/usr/local/bin/thoth --version
/usr/local/bin/thothctl --version
```

**macOS package verification (recommended)**

```bash
pkgutil --check-signature thoth-macos-universal.pkg
spctl --assess --type install --verbose=4 thoth-macos-universal.pkg
xcrun stapler validate thoth-macos-universal.pkg
```

**Linux**

```bash
curl -fsSL https://install.atensecurity.com/thoth | sh
```

**Windows**
Download from Releases: https://github.com/atensecurity/thoth/releases/latest

## Enterprise deployment notes

- macOS release artifacts ship as universal binaries for `thoth` and `thothctl`.
- When Apple Developer ID signing secrets are configured in release automation, the pipeline
  publishes:
  - signed binaries
  - a notarized installer package (`thoth-macos-universal.pkg`)
  - signing metadata (`signing-metadata.json`) for policy teams
- Use publisher/trust-based rules in Santa/Jamf/Intune where possible. Keep SHA256
  allowlisting as a fallback control for emergency pinning.

## Documentation

https://docs.atensecurity.com

## Quick verify

```bash
thoth --version
thothctl --version
thoth doctor
```

## Read The Manuals After Install

After installing a new release, read manuals directly in terminal:

```bash
thoth manual
thothctl manual
```

Add these manual outputs to your internal runbooks before rollout.

## Support

support@atensecurity.com
