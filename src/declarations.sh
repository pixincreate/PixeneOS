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
USER="pixincreate"                    # GitHub username
WORKDIR=".tmp"

VERSION[AFSR]="${VERSION[AFSR]:-77a8c83d52ffb3177eb398bcf53c14459583ce11}" # Commit hash
VERSION[AVBROOT]="${VERSION[AVBROOT]:-3.5.0}"
VERSION[ALTERINSTALLER]="${VERSION[ALTERINSTALLER]:-2.0}"
VERSION[CUSTOTA]="${VERSION[CUSTOTA]:-4.8}"
VERSION[MSD]="${VERSION[MSD]:-1.2}"
VERSION[BCR]="${VERSION[BCR]:-1.69}"
VERSION[OEMUNLOCKONBOOT]="${VERSION[OEMUNLOCKONBOOT]:-1.1}"
VERSION[MAGISK]="${VERSION[MAGISK]:-}"

# Magisk
MAGISK[REPOSITORY]="${USER}/Magisk"
MAGISK[URL]="${DOMAIN}/${MAGISK[REPOSITORY]}"
MAGISK[PREINIT]="${MAGISK[PREINIT]:-sda8}"

# Keys
KEYS[AVB]="${KEYS[AVB]:-avb.key}"
KEYS[CERT_OTA]="${KEYS[CERT_OTA]:-ota.crt}"
KEYS[OTA]="${KEYS[OTA]:-ota.key}"
KEYS[PKMD]="${KEYS[PKMD]:-avb_pkmd.bin}"

# GrapheneOS
GRAPHENEOS[OTA_BASE_URL]="https://releases.grapheneos.org"
GRAPHENEOS[UPDATE_CHANNEL]="alpha"
GRAPHENEOS[UPDATE_TYPE]="${GRAPHENEOS[UPDATE_TYPE]:-ota_update}" # 'ota_update' or 'install'
GRAPHENEOS[VERSION]="${GRAPHENEOS[VERSION]:-latest}"
GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_URL]:-}"       # Will be constructed from the latest version
GRAPHENEOS[OTA_TARGET]="${GRAPHENEOS[OTA_TARGET]:-}" # Will be constructed from the latest version
GRAPHENEOS[ALLOWED_SIGNERS_URL]="${GRAPHENEOS[ALLOWED_SIGNERS]:-}"

# Additionals
ADDITIONALS[AFSR]="${ADDITIONALS[AFSR]:-true}"                         # Android File system repack
ADDITIONALS[ALTERINSTALLER]="${ADDITIONALS[ALTERINSTALLER]:-true}"     # Spoof Android package manager installer fields
ADDITIONALS[AVBROOT]="${ADDITIONALS[AVBROOT]:-true}"                   # Android Verified Boot Root
ADDITIONALS[BCR]="${ADDITIONALS[BCR]:-true}"                           # Basic Call Recorder
ADDITIONALS[CUSTOTA]="${ADDITIONALS[CUSTOTA]:-true}"                   # Custom OTA Updater app
ADDITIONALS[CUSTOTA_TOOL]="${ADDITIONALS[CUSTOTA_TOOL]:-true}"         # Custom OTA Tool
ADDITIONALS[MSD]="${ADDITIONALS[MSD]:-true}"                           # Mass Storage Device on USB
ADDITIONALS[MY_AVBROOT_SETUP]="${ADDITIONALS[MY_AVBROOT_SETUP]:-true}" # My AVBRoot setup
ADDITIONALS[OEMUNLOCKONBOOT]="${ADDITIONALS[OEMUNLOCKONBOOT]:-true}"   # Unlock bootloader on boot
ADDITIONALS[ROOT]="${ADDITIONALS[ROOT]:-false}"                        # Only Magisk is supported
