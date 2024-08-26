#!/bin/bash

set -o nounset -o pipefail -o errexit

source src/fetcher.sh
source src/util_functions.sh

function main() {
  # Fetch the latest version of GrapheneOS and Magisk
  get_latest_version
  # Check for requirements and download them accordingly
  check_and_download_dependencies
  # Patch the OTA, sign it, make a release and push it to the server
  create_and_make_release
}

main "$@"
