declare -A AVBROOT
declare -A MAGISK
declare -A KEYS
declare -A GRAPHENEOS
declare -A ADDITIONALS

# Specifications
CLEANUP="${CLEANUP:-''}" # Clean up after the script finishes
DOMAIN="https://github.com"
DEVICE_NAME="${DEVICE_NAME:-}"
FORCE_UPDATE="${FORCE_UPDATE:-false}" # Push update to device forcefully
WORKDIR="${HOME}/.tmp"

# AVBRoot
AVBROOT[ARCH]="x86_64-unknown-linux-gnu"
AVBROOT[USER]='chenxiaolong'
AVBROOT[REPOSITORIES]="avbroot afsr custota msd bcr oemunlockonboot my-avbroot-setup"
AVBROOT[URL]="${DOMAIN}/${AVBROOT[REPOSITORY]}/releases/download/v${AVBROOT[VERSION]}/avbroot-${AVBROOT[VERSION]}-${ARCH}.zip"
AVBROOT[VERSION]="3.4.1"

# Magisk
MAGISK[REPOSITORY]="pixincreate/Magisk"
MAGISK[VERSION]="${MAGISK[VERSION]:-}"
MAGISK[URL]="${DOMAIN}/${MAGISK[REPOSITORY]}/releases/download/canary-${MAGISK[VERSION]}/app-release.apk"

# Keys
KEYS[AVB]="${KEYS[AVB]:-avb.key}"
KEYS[CERT_OTA]="${KEYS[CERT_OTA]:-ota.crt}"
KEYS[OTA]="${KEYS[OTA]:-ota.key}"

# GrapheneOS
GRAPHENEOS[OTA_BASE_URL]="https://releases.grapheneos.org"
GRAPHENEOS[UPDATE_CHANNEL]="alpha"
GRAPHENEOS[UPDATE_TYPE]="${GRAPHENEOS[UPDATE_TYPE]:-ota_update}" # 'ota_update' or 'factory'
GRAPHENEOS[VERSION]="${GRAPHENEOS[VERSION]:-}"
GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_URL]:-}" # Will be constructed from the latest version

# Additionals
ADDITIONALS[afsr]="${ADDITIONALS[afsr]:-true}"                         # Android File system repack
ADDITIONALS[avbroot]="${ADDITIONALS[avbroot]:-true}"                   # Android Verified Boot Root
ADDITIONALS[bcr]="${ADDITIONALS[bcr]:-true}"                           # Basic Call Recorder
ADDITIONALS[custota]="${ADDITIONALS[custota]:-true}"                   # Custom OTA Updater app
ADDITIONALS[msd]="${ADDITIONALS[msd]:-true}"                           # Mass Storage Device on USB
ADDITIONALS[my_avbroot_setup]="${ADDITIONALS[my_avbroot_setup]:-true}" # My AVBRoot setup
ADDITIONALS[oemunlockonboot]="${ADDITIONALS[oemunlockonboot]:-true}"   # Unlock bootloader on boot
ADDITIONALS[root]="${ADDITIONALS[root]:-false}"                        # Only Magisk is supported
