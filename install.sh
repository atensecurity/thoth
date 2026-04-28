#!/bin/sh
set -eu

REPO="atensecurity/thoth"
INSTALL_DIR="${THOTH_INSTALL_DIR:-/usr/local/bin}"
VERSION="${THOTH_VERSION:-latest}"

bootstrap_thoth_home() {
	if [ -n "${THOTH_HOME_DIR:-}" ]; then
		THOTH_HOME_DIR="${THOTH_HOME_DIR}"
	elif [ -n "${HOME:-}" ]; then
		THOTH_HOME_DIR="${HOME}/.thoth"
	elif [ -n "${USERPROFILE:-}" ]; then
		THOTH_HOME_DIR="${USERPROFILE}/.thoth"
	elif [ -n "${HOMEDRIVE:-}" ] && [ -n "${HOMEPATH:-}" ]; then
		THOTH_HOME_DIR="${HOMEDRIVE}${HOMEPATH}/.thoth"
	else
		echo "warning: could not resolve a home directory; skipping ~/.thoth bootstrap" >&2
		return 0
	fi

	INTENT_MAP_FILE="${THOTH_HOME_DIR}/intent_map.json"
	PROXY_API_KEY_FILE="${THOTH_HOME_DIR}/proxy_api_key.json"

	mkdir -p "${THOTH_HOME_DIR}"
	chmod 700 "${THOTH_HOME_DIR}" 2>/dev/null || true

	if [ ! -f "${INTENT_MAP_FILE}" ]; then
		printf '{}\n' >"${INTENT_MAP_FILE}"
		echo "created ${INTENT_MAP_FILE}"
	fi

	if [ ! -f "${PROXY_API_KEY_FILE}" ]; then
		KEY_ID="${THOTH_API_KEY_ID:-${HOSTNAME:-}}"
		if [ -z "${KEY_ID}" ]; then
			KEY_ID="$(hostname 2>/dev/null || true)"
		fi
		if [ -z "${KEY_ID}" ]; then
			KEY_ID="unknown-host"
		fi

		printf '{\n  "api_key": "",\n  "key_id": "%s"\n}\n' "${KEY_ID}" >"${PROXY_API_KEY_FILE}"
		chmod 600 "${PROXY_API_KEY_FILE}" 2>/dev/null || true
		echo "created ${PROXY_API_KEY_FILE}"
	fi
}

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "${OS}-${ARCH}" in
darwin-arm64 | darwin-x86_64)
	THOTH_ASSET="thoth-macos-universal"
	THOTHCTL_ASSET="thothctl-macos-universal"
	;;
linux-x86_64 | linux-amd64)
	THOTH_ASSET="thoth-linux-x86_64"
	THOTHCTL_ASSET="thothctl-linux-x86_64"
	;;
linux-aarch64 | linux-arm64)
	THOTH_ASSET="thoth-linux-arm64"
	THOTHCTL_ASSET="thothctl-linux-arm64"
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
DOWNLOAD_URL="$(echo "${RELEASE_JSON}" | grep "browser_download_url.*${THOTH_ASSET}\"" | cut -d '"' -f 4)"
DOWNLOAD_URL_CTL="$(echo "${RELEASE_JSON}" | grep "browser_download_url.*${THOTHCTL_ASSET}\"" | cut -d '"' -f 4)"
CHECKSUM_URL="$(echo "${RELEASE_JSON}" | grep 'browser_download_url.*checksums.sha256"' | cut -d '"' -f 4)"

if [ -z "${DOWNLOAD_URL}" ] || [ -z "${DOWNLOAD_URL_CTL}" ] || [ -z "${CHECKSUM_URL}" ]; then
	echo "Could not resolve release assets for ${THOTH_ASSET}/${THOTHCTL_ASSET}" >&2
	exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/thoth"
curl -fsSL "${DOWNLOAD_URL_CTL}" -o "${TMP_DIR}/thothctl"
curl -fsSL "${CHECKSUM_URL}" -o "${TMP_DIR}/checksums.sha256"

echo "Verifying checksum..."
(
	cd "${TMP_DIR}"
	EXPECTED_LINE_THOTH="$(grep " ${THOTH_ASSET}\$" checksums.sha256 || true)"
	EXPECTED_LINE_CTL="$(grep " ${THOTHCTL_ASSET}\$" checksums.sha256 || true)"
	if [ -z "${EXPECTED_LINE_THOTH}" ] || [ -z "${EXPECTED_LINE_CTL}" ]; then
		echo "Missing ${THOTH_ASSET} or ${THOTHCTL_ASSET} entry in checksums.sha256" >&2
		exit 1
	fi
	CHECKSUM_THOTH="$(echo "${EXPECTED_LINE_THOTH}" | awk '{print $1}')"
	CHECKSUM_CTL="$(echo "${EXPECTED_LINE_CTL}" | awk '{print $1}')"
	printf "%s  %s\n" "${CHECKSUM_THOTH}" "thoth" >check.txt
	printf "%s  %s\n" "${CHECKSUM_CTL}" "thothctl" >>check.txt
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum -c check.txt
	else
		shasum -a 256 -c check.txt
	fi
)

# Guard against a known bad release state where Linux assets are dynamically
# linked against musl (interpreter /lib/ld-musl-*.so.1), which fails on most
# Ubuntu hosts with "No such file or directory".
if [ "${OS}" = "linux" ] && command -v readelf >/dev/null 2>&1; then
	for bin in thoth thothctl; do
		INTERP_LINE="$(readelf -l "${TMP_DIR}/${bin}" 2>/dev/null | grep "Requesting program interpreter" || true)"
		if echo "${INTERP_LINE}" | grep -q "/lib/ld-musl"; then
			echo "Downloaded artifact ${bin} requires musl loader but this host likely lacks it:" >&2
			echo "  ${INTERP_LINE}" >&2
			echo "Expected a statically linked Linux artifact. Please retry after the release is republished." >&2
			exit 1
		fi
	done
fi

mkdir -p "${INSTALL_DIR}"
chmod +x "${TMP_DIR}/thoth"
chmod +x "${TMP_DIR}/thothctl"

if [ -w "${INSTALL_DIR}" ]; then
	mv "${TMP_DIR}/thoth" "${INSTALL_DIR}/thoth"
	mv "${TMP_DIR}/thothctl" "${INSTALL_DIR}/thothctl"
else
	sudo mv "${TMP_DIR}/thoth" "${INSTALL_DIR}/thoth"
	sudo mv "${TMP_DIR}/thothctl" "${INSTALL_DIR}/thothctl"
fi

echo "thoth installed to ${INSTALL_DIR}/thoth"
echo "thothctl installed to ${INSTALL_DIR}/thothctl"
bootstrap_thoth_home
"${INSTALL_DIR}/thoth" --version
"${INSTALL_DIR}/thothctl" --version
echo "Run 'thoth doctor' to verify your environment."
