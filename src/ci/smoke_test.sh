#!/usr/bin/env bash

# Verify that every download URL the project constructs still resolves.
# Catches renamed release assets and version drift before a release run does.

set -o nounset -o pipefail -o errexit

source src/util_functions.sh

FAILED=0

function check_url() {
  local name="${1}"
  local url="${2}"
  local status

  status=$(curl -sIL -o /dev/null -w '%{http_code}' "${url}")
  if [[ "${status}" == "200" ]]; then
    echo "ok   ${name}: ${url}"
  else
    echo "::error::FAIL ${name} (HTTP ${status}): ${url}"
    FAILED=1
  fi
}

# Read the device configuration and resolve the latest versions
check_toml_env
get_latest_version

# Tools and modules from declarations
tool_list=$(supported_tools "cdd")
IFS=' ' read -r -a tools_array <<<"${tool_list}"

for tool in "${tools_array[@]}"; do
  # `my-avbroot-setup` is a git repository, cloning is checked elsewhere
  if [[ "${tool}" == "my-avbroot-setup" ]]; then
    continue
  fi

  construct_url "${tool}"
  check_url "${tool}" "${URL}"
  check_url "${tool}.sig" "${SIGNATURE_URL}"
done

# Magisk APK from the fork's latest tag
check_url "magisk" "${MAGISK[URL]}/releases/download/${VERSION[MAGISK]}/Magisk-${VERSION[MAGISK]}.apk"

# GrapheneOS OTA for the configured device
check_url "grapheneos-ota" "${GRAPHENEOS[OTA_URL]}"

exit "${FAILED}"
