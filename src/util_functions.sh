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

generate_keys() {
  local public_key_metadata='avb_pkmd.bin'

  # Generate the AVB and OTA signing keys
  avbroot key generate-key -o "${KEY_AVB}"
  avbroot key generate-key -o "${KEY_OTA}"

  # Convert the public key portion of the AVB signing key to the AVB public key metadata format
  # This is the format that the bootloader requires when setting the custom root of trust
  avbroot key extract-avb -k "${KEY_AVB}" -o "${public_key_metadata}"

  # Generate a self-signed certificate for the OTA signing key
  # This is used by recovery to verify OTA updates when sideloading
  avbroot key generate-cert -k "${KEY_OTA}" -o "${CERT_OTA}"
}

get_latest_version() {
  local latest_grapheneos_version=$(curl -sL "${GRAPHENEOS[OTA_BASE_URL]}/${DEVICE_NAME}-${GRAPHENEOS[UPDATE_CHANNEL]}" | sed 's/ .*//')
  local latest_magisk_version=$(
    git ls-remote --tags "${DOMAIN}/${MAGISK[REPOSITORY]}.git" \
      | awk -F'\t' '{print $2}' \
      | grep -E 'refs/tags/' \
      | sed 's/refs\/tags\///' \
      | sort -V \
      | tail -n1 \
      | sed 's/canary-//'
  )

  OTA_TARGET="${DEVICE_NAME}-${GRAPHENEOS[UPDATE_TYPE]}-${latest_grapheneos_version}"
  GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_BASE_URL]}/${OTA_TARGET}.zip"
  # e.g.  bluejay-ota_update-2024080200
  echo -e "OTA target: ${OTA_TARGET}\nOTA URL: ${GRAPHENEOS[OTA_URL]}"

  if [ -z "${latest_grapheneos_version}" ]; then
    echo "Failed to get the latest version."
    exit 1
  fi

  if [ -z "${GRAPHENEOS[VERSION]}" ]; then
    GRAPHENEOS[VERSION]="${latest_grapheneos_version}"
  fi

  if [ -z "${latest_magisk_version}" ]; then
    echo "Failed to get the latest Magisk version."
    exit 1
  fi

  if [ -z "${MAGISK[VERSION]}" ]; then
    MAGISK[VERSION]="${latest_magisk_version}"
  fi
}

patch_ota() {

  avbroot ota patch \
    --input /path/to/ota.zip \
    --key-avb /path/to/avb.key \
    --key-ota /path/to/ota.key \
    --cert-ota /path/to/ota.crt
}