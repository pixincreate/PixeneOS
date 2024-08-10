declare -A AVBROOT
declare -A MAGISK
declare -A KEYS
declare -A GRAPHENEOS
declare -A ADDITIONALS
declare -A VERSION

# Specifications
CLEANUP="${CLEANUP:-''}" # Clean up after the script finishes
DOMAIN="https://github.com"
DEVICE_NAME="${DEVICE_NAME:-bluejay}" # Device name, passed from the CI environment
FORCE_UPDATE="${FORCE_UPDATE:-false}" # Push update to device forcefully
WORKDIR=".tmp"

VERSION[AVBROOT]="${VERSION[AVBROOT]:-3.4.1}"
VERSION[ALTERINSTALLER]="${VERSION[ALTERINSTALLER]:-2.0}"
VERSION[CUSTOTA]="${VERSION[CUSTOTA]:-4.7}"
VERSION[MSD]="${VERSION[MSD]:-1.1}"
VERSION[BCR]="${VERSION[BCR]:-1.69}"
VERSION[OEMUNLOCKONBOOT]="${VERSION[OEMUNLOCKONBOOT]:-1.1}"
VERSION[MAGISK]="${VERSION[MAGISK]:-}"

# Magisk
MAGISK[REPOSITORY]="pixincreate/Magisk"
MAGISK[URL]="${DOMAIN}/${MAGISK[REPOSITORY]}"
MAGISK[PREINIT]="${MAGISK[PREINIT]:-sda8}"

# Keys
KEYS[AVB]="${KEYS[AVB]:-avb.key}"
KEYS[CERT_OTA]="${KEYS[CERT_OTA]:-ota.crt}"
KEYS[OTA]="${KEYS[OTA]:-ota.key}"

# GrapheneOS
GRAPHENEOS[OTA_BASE_URL]="https://releases.grapheneos.org"
GRAPHENEOS[UPDATE_CHANNEL]="alpha"
GRAPHENEOS[UPDATE_TYPE]="${GRAPHENEOS[UPDATE_TYPE]:-ota_update}" # 'ota_update' or 'install'
GRAPHENEOS[VERSION]="${GRAPHENEOS[VERSION]:-}"
GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_URL]:-}"       # Will be constructed from the latest version
GRAPHENEOS[OTA_TARGET]="${GRAPHENEOS[OTA_TARGET]:-}" # Will be constructed from the latest version
GRAPHENEOS[ALLOWED_SIGNERS_URL]="${GRAPHENEOS[ALLOWED_SIGNERS]:-}"

# Additionals
ADDITIONALS[AFSR]="${ADDITIONALS[AFSR]:-true}"                         # Android File system repack
ADDITIONALS[ALTERINSTALLER]="${ADDITIONALS[ALTERINSTALLER]:-false}"    # Spoof Android package manager installer fields
ADDITIONALS[AVBROOT]="${ADDITIONALS[AVBROOT]:-true}"                   # Android Verified Boot Root
ADDITIONALS[BCR]="${ADDITIONALS[BCR]:-true}"                           # Basic Call Recorder
ADDITIONALS[CUSTOTA]="${ADDITIONALS[CUSTOTA]:-true}"                   # Custom OTA Updater app
ADDITIONALS[MSD]="${ADDITIONALS[MSD]:-false}"                          # Mass Storage Device on USB
ADDITIONALS[MY_AVBROOT_SETUP]="${ADDITIONALS[MY_AVBROOT_SETUP]:-true}" # My AVBRoot setup
ADDITIONALS[OEMUNLOCKONBOOT]="${ADDITIONALS[OEMUNLOCKONBOOT]:-true}"   # Unlock bootloader on boot
ADDITIONALS[ROOT]="${ADDITIONALS[ROOT]:-false}"                        # Only Magisk is supported
