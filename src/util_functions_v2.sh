. ./declarations.sh
. ./downloader.sh

check_dependencies() {
  mkdir -p "${WORKDIR}"

  # Check for required tools
  # If they're present, continue with the script
  # Else, download them by checking version from declarations
  local tools=("avbroot" "afsr" "custota" "msd" "bcr" "oemunlockonboot" "magisk" "my-avbroot-setup")
  for tool in "${tools[@]}"; do
    if [ -e "${WORKDIR}/${tool}" ]; then
      download_dependencies
    fi
  done

  # my-avbroot-setup has got it all covered
  verify_downloads
}

download_dependencies() {
  # Download the required tools
  # If the tools are already present, skip the download
  # Else, download them
  download
}

verify_downloads() {
  # Verify the downloaded tools
  # If the tools are not present, exit the script
  # Else, continue with the script
  verify
}

create_and_make_release() {
  create_ota
  release_ota
  push_to_server
}

create_ota() {
  [[ "${CLEANUP}" != 'true' ]] && trap cleanup EXIT ERR

  get_latest_version
  download_ota
  patch_ota
}

cleanup() {
  echo "Cleaning up..."
  rm -rf "${WORKDIR}"
  unset "${KEYS[@]}"
  echo "Cleanup complete."
}
