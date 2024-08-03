#!/bin/bash

source declarations.sh

get_avbroot() {
  if [ ! -d "${AVBROOT_DIR}" ]; then
    mkdir -p "${AVBROOT_DIR}"

    echo "Downloading from: $AVBROOT_URL"
    curl -sL "${AVBROOT_URL}" --output "${AVBROOT_ZIP_FILE}"
    curl -sL "${AVBROOT_SIGNATURE_URL}" --output "${AVBROOT_ZIP_FILE}.sig"

    echo "Extracting to: ${AVBROOT_DIR}"
    echo N | unzip -q "${AVBROOT_ZIP_FILE}" -d "${AVBROOT_DIR}"

    echo "Verifying the signature"
    verify_avbroot_signature
    chmod +x "${AVBROOT_DIR}/avbroot"
    export PATH="${AVBROOT_DIR}:${PATH}"

    rm "${AVBROOT_ZIP_FILE}"
  else
    echo "\`avbroot\` is already installed in: ${AVBROOT_DIR}"
  fi
}

verify_avbroot_signature() {
  local signature='AAAAC3NzaC1lZDI1NTE5AAAAIDOe6/tBnO7xZhAWXRj3ApUYgn+XZ0wnQiXM8B7tPgv4'
  local keys='trust_keys'
  local expected_message='Good "file" signature for chenxiaolong with ED25519 key SHA256:Ct0HoRyrFLrnF9W+A/BKEiJmwx7yWkgaW/JvghKrboA'

  echo chenxiaolong ssh-ed25519 ${signature} > "${keys}"
  local actual_message=$(ssh-keygen -Y verify -f "${keys}" -I chenxiaolong -n file -s "${AVBROOT_ZIP_FILE}.sig" < "${AVBROOT_ZIP_FILE}")

  compare "${actual_message}" "${expected_message}"
}

verify_ota_signature() {
  local contact_email='contact@grapheneos.org'
  local expected_message='Good "factory images" signature for contact@grapheneos.org with ED25519 key SHA256:AhgHif0mei+9aNyKLfMZBh2yptHdw/aN7Tlh/j2eFwM'
  if [ "${GRAPHENEOS_UPDATE_TYPE}" == 'factory']; then
    local actual_message=$(
      ssh-keygen -Y verify -f allowed_signers -I "${contact_email}" \
        -n "factory images" \
        -s "${DEVICE_NAME}-${GRAPHENEOS_UPDATE_TYPE}-${GRAPHENEOS_VERSION}.zip.sig" < "${DEVICE_NAME}-${GRAPHENEOS_UPDATE_TYPE}-${GRAPHENEOS_VERSION}.zip"
    )
  fi

  compare "${actual_message}" "${expected_message}"
}

compare() {
  local actual=$1
  local expected=$2

  if [[ "${actual}" == "${expected}" ]]; then
    echo "Verification successful: The output matches the expected message."
  else
    echo "Verification failed: The output does not match the expected message."
    echo "Expected message: ${expected}"
    echo "Actual message: ${actual}"
  fi
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

path_ota() {
  local arguments=()

  

  avbroot ota patch \
    --input /path/to/ota.zip \
    --key-avb /path/to/avb.key \
    --key-ota /path/to/ota.key \
    --cert-ota /path/to/ota.crt

  avbroot "${arguments[@]}"
}

get_latest_version() {
  local latest_grapheneos_version=$(curl -sL "${GRAPHENEOS_OTA_BASE_URL}/${DEVICE_NAME}-${GRAPHENEOS_UPDATE_CHANNEL}" | sed 's/ .*//')
  local latest_magisk_version=$(
    git ls-remote --tags "${DOMAIN}/${MAGISK_REPOSITORY}.git" \
      | awk -F'\t' '{print $2}' \
      | grep -E 'refs/tags/' \
      | sed 's/refs\/tags\///' \
      | sort -V \
      | tail -n1 \
      | sed 's/canary-//'
  )

  OTA_TARGET="${DEVICE_NAME}-${GRAPHENEOS_UPDATE_TYPE}-${latest_grapheneos_version}"
  GRAPHENEOS_OTA_URL="${GRAPHENEOS_OTA_BASE_URL}/${OTA_TARGET}.zip"
  # e.g.  bluejay-ota_update-2024080200
  echo -e "OTA target: ${OTA_TARGET}\nOTA URL: ${OTA_URL}"

  if [ -z "${latest_grapheneos_version}" ]; then
    echo "Failed to get the latest version."
    exit 1
  fi

  if [ -z "${GRAPHENEOS_VERSION}" ]; then
    GRAPHENEOS_VERSION="${latest_grapheneos_version}"
  fi

  if [ -z "${latest_magisk_version}" ]; then
    echo "Failed to get the latest Magisk version."
    exit 1
  fi

  if [ -z "${MAGISK_VERSION}" ]; then
    MAGISK_VERSION="${latest_magisk_version}"
  fi
}

download_ota() {
  local ota_location="${AVBROOT_DIR}/$OTA_TARGET.zip"
  local ota_signature_location="${AVBROOT_DIR}/$OTA_TARGET.zip.sig"
  local magisk_location="${AVBROOT_DIR}/magisk-canary-${MAGISK_VERSION}.apk"

  if [ -z "${ota_location}" ]; then
    echo "Downloading OTA from: $GRAPHENEOS_OTA_URL"
    curl -sL "${GRAPHENEOS_OTA_URL}" --output ${ota_location}
    curl -sL "${GRAPHENEOS_OTA_URL}.sig" --output ${ota_signature_location}
    verify_ota_signature
    echo "OTA downloaded to: ${ota_location}"
  fi
  if [ -z "${magisk_location}" ]; then
    echo "Downloading Magisk from: $MAGISK_URL"
    curl -sL "${MAGISK_URL}" --output "${magisk_location}"
    echo "Magisk downloaded to: ${magisk_location}"
  fi
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
  rm -rf "${AVBROOT_DIR}"
  echo "Cleanup complete."
}
