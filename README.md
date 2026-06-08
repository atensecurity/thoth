# thoth

Thoth MCP governance runtime + headless control-plane CLI.
Governs MCP tool calls through the Moses enforcement pipeline and supports
GitOps-first tenant bootstrap via `thothctl`.

## Install

**macOS / Linux**

```bash
curl -fsSL https://install.atensecurity.com/thoth | sh
```

**macOS (Homebrew)**

```bash
brew tap atensecurity/homebrew-tap
brew install thoth
```

**Windows**
Download from Releases: https://github.com/atensecurity/thoth/releases/latest

## Enterprise deployment notes

- macOS release artifacts ship as universal binaries for `thoth` and `thothctl`.
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
