#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<EOF
Usage: $0 <checksums.sha256> [file ...]

Examples:
  $0 checksums.sha256
  $0 checksums.sha256 thoth-linux-x86_64 thoth-macos-universal
EOF
}

if [[ $# -lt 1 ]]; then
	usage >&2
	exit 1
fi

CHECKSUM_FILE="$1"
shift

if [[ ! -f ${CHECKSUM_FILE} ]]; then
	echo "Checksum file not found: ${CHECKSUM_FILE}" >&2
	exit 1
fi

if [[ $# -eq 0 ]]; then
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum --check "${CHECKSUM_FILE}"
	else
		shasum -a 256 --check "${CHECKSUM_FILE}"
	fi
	exit 0
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

for file in "$@"; do
	if ! grep -F " ${file}" "${CHECKSUM_FILE}" >>"${TMP_FILE}"; then
		echo "No checksum entry found for ${file}" >&2
		exit 1
	fi
done

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum --check "${TMP_FILE}"
else
	shasum -a 256 --check "${TMP_FILE}"
fi
