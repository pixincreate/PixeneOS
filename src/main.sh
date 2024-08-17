#!/bin/bash

source src/fetcher.sh
source src/util_functions.sh

function main() {
  local autorun="${1:-true}"

  if [[ "${autorun}" == 'true' ]]; then
    # If the script is run in autorun mode, skip the prompt
    echo -e "Running in autorun mode...\n"
  else
    # Prompt the user to confirm the action
    echo -e "This script will fetch the latest version of GrapheneOS and Magisk, patch the OTA, sign it, make a release and push it to the server.\n"
    echo -n "Do you want to continue? (y/n): "
    read confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
      echo -e "Exiting..."
      exit 1
    fi
  fi

  # Fetch the latest version of GrapheneOS and Magisk
  get_latest_version
  # Check for requirements and download them accordingly
  check_and_download_dependencies
  # Patch the OTA, sign it, make a release and push it to the server
  create_and_make_release
  # Perform cleanup
  cleanup
}

main "$@"
