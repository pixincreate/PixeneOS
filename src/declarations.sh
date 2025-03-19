# Declare associative arrays and variables
declare -A ADDITIONALS
declare -A AVBROOT
declare -A GRAPHENEOS
declare -A KEYS
declare -A MAGISK
declare -A OUTPUTS
declare -A VERSION

# Build Specifications
ARCH="x86_64-unknown-linux-gnu" # for Linux
# ARCH="universal-apple-darwin" # for macOS
# ARCH="x86_64-pc-windows-msvc" # for Windows

# Initial setup environment variables
CLEANUP="${CLEANUP:-'false'}"                # Clean up after the script finishes
DEVICE_NAME="${DEVICE_NAME:-}"               # Device name, passed from the CI environment
INTERACTIVE_MODE="${INTERACTIVE_MODE:-true}" # Enable interactive mode
WORKDIR=".tmp"

# GitHub variables
DOMAIN="https://github.com"
REPOSITORY="PixeneOS" # GitHub repository name
USER="pixincreate"    # GitHub username

# Application version variables
VERSION[AFSR]="${VERSION[AFSR]:-1.0.3}"
VERSION[ALTERINSTALLER]="${VERSION[ALTERINSTALLER]:-2.0}"
VERSION[AVBROOT]="${VERSION[AVBROOT]:-3.13.0}"
VERSION[AVBROOT_SETUP]="16636c3" # Commit hash
VERSION[BCR]="${VERSION[BCR]:-1.77}"
VERSION[CUSTOTA]="${VERSION[CUSTOTA]:-5.7}"
VERSION[GRAPHENEOS]="${VERSION[GRAPHENEOS]:-}"
VERSION[MAGISK]="${VERSION[MAGISK]:-}"
VERSION[MSD]="${VERSION[MSD]:-1.12}"
VERSION[OEMUNLOCKONBOOT]="${VERSION[OEMUNLOCKONBOOT]:-1.1}"

# Magisk
MAGISK[PREINIT]="${MAGISK_PREINIT:-}"
MAGISK[REPOSITORY]="${USER}/Magisk"
MAGISK[URL]="${DOMAIN}/${MAGISK[REPOSITORY]}"

# Keys
KEYS[AVB]="${KEYS[AVB]:-avb.key}"
KEYS[AVB_BASE64]="${KEYS[AVB_BASE64]:-''}"
KEYS[CERT_OTA]="${KEYS[CERT_OTA]:-ota.crt}"
KEYS[CERT_OTA_BASE64]="${KEYS[CERT_OTA_BASE64]:-''}"
KEYS[OTA]="${KEYS[OTA]:-ota.key}"
KEYS[OTA_BASE64]="${KEYS[OTA_BASE64]:-''}"
KEYS[PKMD]="${KEYS[PKMD]:-avb_pkmd.bin}"

# GrapheneOS
GRAPHENEOS[OTA_BASE_URL]="https://releases.grapheneos.org"
GRAPHENEOS[UPDATE_CHANNEL]="${GRAPHENEOS_UPDATE_CHANNEL:-stable}"
GRAPHENEOS[UPDATE_TYPE]="${GRAPHENEOS[UPDATE_TYPE]:-ota_update}" # avbroot supports only `ota_update` and not `install` (factory images)
GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_URL]:-}"                   # Will be constructed from the latest version
GRAPHENEOS[OTA_TARGET]="${GRAPHENEOS[OTA_TARGET]:-}"             # Will be constructed from the latest version

# Additionals

# Modules
ADDITIONALS[AFSR]="${ADDITIONALS[AFSR]:-true}"                       # Android File system repack
ADDITIONALS[ALTERINSTALLER]="${ADDITIONALS[ALTERINSTALLER]:-true}"   # Spoof Android package manager installer fields
ADDITIONALS[BCR]="${ADDITIONALS[BCR]:-true}"                         # Basic Call Recorder
ADDITIONALS[CUSTOTA]="${ADDITIONALS[CUSTOTA]:-true}"                 # Custom OTA Updater app
ADDITIONALS[MSD]="${ADDITIONALS[MSD]:-true}"                         # Mass Storage Device on USB
ADDITIONALS[OEMUNLOCKONBOOT]="${ADDITIONALS[OEMUNLOCKONBOOT]:-true}" # toggle OEM unlock button on boot
# Tools
ADDITIONALS[AVBROOT]="${ADDITIONALS[AVBROOT]:-true}"                   # Android Verified Boot Root
ADDITIONALS[CUSTOTA_TOOL]="${ADDITIONALS[CUSTOTA_TOOL]:-true}"         # Custom OTA Tool
ADDITIONALS[MY_AVBROOT_SETUP]="${ADDITIONALS[MY_AVBROOT_SETUP]:-true}" # My AVBRoot setup

ADDITIONALS[ROOT]="${ADDITIONALS_ROOT:-false}"   # Only Magisk is supported
ADDITIONALS[RETRY]="${ADDITIONALS[RETRY]:-true}" # Auto download signatures

# Outputs
OUTPUTS[PATCHED_OTA]="${OUTPUTS[PATCHED_OTA]:-}"
