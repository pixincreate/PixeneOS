#!/bin/bash

# Declarations
# GitHub repository
DOMAIN="https://github.com"
AVBROOT_REPOSITORY="chenxiaolong/avbroot"
ARCH="x86_64-unknown-linux-gnu"
MAGISK_REPOSITORY="pixincreate/Magisk" # My fork with Zygisk support for GrapheneOS

# AVBRoot
AVBROOT_VERSION="3.4.1"

AVBROOT_URL="${DOMAIN}/${REPOSITORY}/releases/download/v${AVBROOT_VERSION}/avbroot-${AVBROOT_VERSION}-${ARCH}.zip"
AVBROOT_SIGNATURE_URL="${DOMAIN}/${REPOSITORY}/releases/download/v${AVBROOT_VERSION}/avbroot-${AVBROOT_VERSION}-${ARCH}.zip.sig"

AVBROOT_DIR="${HOME}/avbroot"
AVBROOT_ZIP_FILE="${AVBROOT_DIR}/avbroot-${AVBROOT_VERSION}-${ARCH}.zip"

# Magisk
MAGISK_VERSION=${MAGISK_VERSION:-}
MAGISK_URL="${DOMAIN}/${MAGISK_REPOSITORY}/releases/download/canary-${MAGISK_VERSION}/app-release.apk"

# Keys
KEY_AVB=${KEY_AVB:-avb.key}
KEY_OTA=${KEY_OTA:-ota.key}
CERT_OTA=${CERT_OTA:-ota.crt}

# Device
DEVICE_NAME=${DEVICE_NAME:-}

GRAPHENEOS_OTA_BASE_URL="https://releases.grapheneos.org"
GRAPHENEOS_UPDATE_CHANNEL='alpha'
GRAPHENEOS_VERSION=${GRAPHENEOS_VERSION:-}
GRAPHENEOS_UPDATE_TYPE=${GRAPHENEOS_UPDATE_TYPE:-'ota_update'} # 'ota_update' or 'factory'
GRAPHENEOS_OTA_URL=${GRAPHENEOS_OTA_URL:-}

# Additionals
BCR=${BCR:-true}                               # Basic Call Recorder
CUSTOTA=${CUSTOTA:-true}                       # Custom OTA Updater app
FORCE_UPDATE=${FORCE_UPDATE:-false}            # Push update to device forcefully
MSD=${MSD:-true}                               # Mass Storage Device on USB
OEM_UNLOCK_ON_BOOT=${OEM_UNLOCK_ON_BOOT:-true} # Unlock bootloader on boot
ROOT=${ROOT:-false}                            # Only Magisk is supported

CLEANUP=${CLEANUP:-''} # Clean up after the script finishes
