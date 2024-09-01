#!/bin/bash

# This project is highly dependent on chenxiaolong's projects.
# Project PixeneOS needs to be up-to-date with chenxiaolong's projects

# make code more robust by catching unset variables, detecting errors in pipelines, and halting execution upon encountering errors
set -o nounset -o pipefail -o errexit

source src/fetcher.sh
source src/util_functions.sh

function main() {
  # Fetch the latest version of GrapheneOS and Magisk
  get_latest_version
  # Check for requirements and download them accordingly
  check_and_download_dependencies
  # Patch the OTA, sign it
  create_and_make_release
}

main "$@"
