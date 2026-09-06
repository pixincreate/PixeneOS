#!/usr/bin/env bash

# Delete older assets of the current device and flavor from the release.
# Keeps a single build per device and flavor. Without this, rebuilds pile up
# assets and the module update check keeps matching the oldest asset.
#
# Reads from the environment:
#   DEVICE_NAME          Device code name
#   GRAPHENEOS_VERSION   GrapheneOS version of the release
#   OUTPUTS_PATCHED_OTA  File name of the build that has to stay
#   REPOSITORY           GitHub repository as `owner/name`
#   ROOT                 "true" targets the magisk flavor, anything else rootless
#   GH_TOKEN             Token for the `gh` CLI

set -o nounset -o pipefail -o errexit

build_flavor=$([[ "${ROOT:-false}" == "true" ]] && echo 'magisk' || echo 'rootless')

gh release view "${GRAPHENEOS_VERSION}" --repo "${REPOSITORY}" --json assets --jq '.assets[].name' |
  { grep -E "^${DEVICE_NAME}-${GRAPHENEOS_VERSION}-${build_flavor}-" || true; } |
  { grep -v -F "${OUTPUTS_PATCHED_OTA}" || true; } |
  while read -r asset; do
    echo "Deleting superseded asset: ${asset}"
    gh release delete-asset "${GRAPHENEOS_VERSION}" "${asset}" --repo "${REPOSITORY}" --yes
  done
