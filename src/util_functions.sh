. src/declarations.sh
. src/downloader.sh
. src/verifier.sh

check_dependencies() {
  mkdir -p "${WORKDIR}"

  # Fetch the latest version of GrapheneOS and Magisk
  get_latest_version

  # Check for required tools
  # If they're present, continue with the script
  # Else, download them by checking version from declarations
  local tools=("avbroot" "afsr" "custota" "msd" "bcr" "oemunlockonboot" "my-avbroot-setup")
  for tool in "${tools[@]}"; do
    if [ ! -e "${WORKDIR}/${tool}" ]; then
      echo -e "${tool} is non-existent. Downloading..."
      download_dependencies ${tool}
    else
      echo -e "${tool} is already installed in: ${WORKDIR}/${tool}"
      continue
    fi
  done

  if [ "${ADDITIONALS[ROOT]}" ]; then
    get "magisk" "${MAGISK[URL]}/releases/download/canary-${VERSION[MAGISK]}/app-release.apk"
  fi

  verify_downloads
}

create_and_make_release() {
  create_ota
  release_ota
  push_to_server
}

create_ota() {
  [[ "${CLEANUP}" != 'true' ]] && trap cleanup EXIT ERR

  download_ota
  modify_setup_script
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

  GRAPHENEOS[OTA_TARGET]="${DEVICE_NAME}-${GRAPHENEOS[UPDATE_TYPE]}-${latest_grapheneos_version}"
  GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_BASE_URL]}/${GRAPHENEOS[OTA_TARGET]}.zip"

  # e.g.  bluejay-ota_update-2024080200
  echo -e "GrapheneOS OTA target: ${OTA_TARGET}\nGrapeheneOS OTA URL: ${GRAPHENEOS[OTA_URL]}\n"

  if [ -z "${latest_grapheneos_version}" ]; then
    echo -e "Failed to get the latest version."
    exit 1
  fi

  if [ -z "${GRAPHENEOS[VERSION]}" ]; then
    GRAPHENEOS[VERSION]="${latest_grapheneos_version}"
  fi

  if [ -z "${latest_magisk_version}" ]; then
    echo -e "Failed to get the latest Magisk version."
    exit 1
  fi

  if [ -z "${VERSION[MAGISK]}" ]; then
    VERSION[MAGISK]="${latest_magisk_version}"
  fi
}

modify_setup_script() {
  local setup_script="${WORKDIR}/my-avbroot-setup/patch.py"
  local magisk_path="${WORKDIR}\/magisk.apk"

  if [ "${ADDITIONALS[ROOT]}" ]; then
    sed -i \
      "s/--rootless/--magisk ${magisk_path}/a --magisk-preinit-device ${MAGISK[PREINIT]}/" \
      "${setup_script}"
  fi
}

patch_ota() {
  local ota_zip="${WORKDIR}/${GRAPHENEOS[OTA_TARGET]}.zip"
  local public_key_metadata='avb_pkmd.bin'

  python3 patch.py \
    --input "${ota_zip}" \
    --verify-public-key-avb "${public_key_metadata}" \
    --verify-cert-ota "${KEY[CERT_OTA]}" \
    --sign-key-avb "${KEYS[AVB]}" \
    --sign-key-ota "${KEYS[OTA]}" \
    --sign-cert-ota sign_cert.key \
    --module-custota custota.zip \
    --module-msd msd.zip \
    --module-bcr bcr.zip \
    --module-oemunlockonboot oemunlockonboot.zip
}
