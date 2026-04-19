#!/bin/sh
set -eu

REPO="atensecurity/thoth"
INSTALL_DIR="${THOTH_INSTALL_DIR:-/usr/local/bin}"
VERSION="${THOTH_VERSION:-latest}"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "${OS}-${ARCH}" in
  darwin-arm64|darwin-x86_64)
    ASSET="thoth-macos-universal"
    ;;
  linux-x86_64|linux-amd64)
    ASSET="thoth-linux-x86_64"
    ;;
  linux-aarch64|linux-arm64)
    ASSET="thoth-linux-arm64"
    ;;
  *)
    echo "Unsupported platform: ${OS}-${ARCH}" >&2
    echo "Download manually: https://github.com/${REPO}/releases/latest" >&2
    exit 1
    ;;
esac

if [ "${VERSION}" = "latest" ]; then
  API_URL="https://api.github.com/repos/${REPO}/releases/latest"
else
  API_URL="https://api.github.com/repos/${REPO}/releases/tags/v${VERSION}"
fi

echo "Fetching thoth ${VERSION} for ${OS}-${ARCH}..."

RELEASE_JSON="$(curl -fsSL "${API_URL}")"
DOWNLOAD_URL="$(echo "${RELEASE_JSON}" | grep "browser_download_url.*${ASSET}\"" | cut -d '"' -f 4)"
CHECKSUM_URL="$(echo "${RELEASE_JSON}" | grep "browser_download_url.*checksums.sha256\"" | cut -d '"' -f 4)"

if [ -z "${DOWNLOAD_URL}" ] || [ -z "${CHECKSUM_URL}" ]; then
  echo "Could not resolve release assets for ${ASSET}" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/thoth"
curl -fsSL "${CHECKSUM_URL}" -o "${TMP_DIR}/checksums.sha256"

echo "Verifying checksum..."
(
  cd "${TMP_DIR}"
  EXPECTED_LINE="$(grep " ${ASSET}\$" checksums.sha256 || true)"
  if [ -z "${EXPECTED_LINE}" ]; then
    echo "Missing ${ASSET} entry in checksums.sha256" >&2
    exit 1
  fi
  CHECKSUM="$(echo "${EXPECTED_LINE}" | awk '{print $1}')"
  printf "%s  %s\n" "${CHECKSUM}" "thoth" > check.txt
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c check.txt
  else
    shasum -a 256 -c check.txt
  fi
)

mkdir -p "${INSTALL_DIR}"
chmod +x "${TMP_DIR}/thoth"

if [ -w "${INSTALL_DIR}" ]; then
  mv "${TMP_DIR}/thoth" "${INSTALL_DIR}/thoth"
else
  sudo mv "${TMP_DIR}/thoth" "${INSTALL_DIR}/thoth"
fi

echo "thoth installed to ${INSTALL_DIR}/thoth"
"${INSTALL_DIR}/thoth" --version
echo "Run 'thoth doctor' to verify your environment."
