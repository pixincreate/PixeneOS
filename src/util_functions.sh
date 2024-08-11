. src/declarations.sh
. src/downloader.sh
. src/verifier.sh

check_dependencies() {
  mkdir -p "${WORKDIR}"

  # Fetch the latest version of GrapheneOS and Magisk
  get_latest_version

  # Check for Python requirements
  if ! command -v python3 &> /dev/null; then
    echo -e "Python 3 is required to run this script.\nExiting..."
    exit 1
  fi

  # Check for required tools
  # If they're present, continue with the script
  # Else, download them by checking version from declarations
  local tools=("avbroot" "afsr" "alterinstaller" "custota" "msd" "bcr" "oemunlockonboot" "my-avbroot-setup")
  for tool in "${tools[@]}"; do
    local flag=$(flag_check "${tool}")
    if [ "${flag}" == 'false' ]; then
      echo -e "\`${tool}\` is **NOT** enabled in the configuration.\nSkipping...\n"
      continue
    fi

    local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

    if [ ! -e "${WORKDIR}/${tool}" ]; then
      download_dependencies "${tool}"
    else
      echo -e "${tool} is already installed in: ${WORKDIR}/${tool}"
      continue
    fi
    verify_downloads "${tool}"
  done

  if [ "${ADDITIONALS[ROOT]}" == 'true' ]; then
    get "magisk" "${MAGISK[URL]}/releases/download/canary-${VERSION[MAGISK]}/app-release.apk"
    verify_downloads "magisk.apk"
  fi
}

flag_check() {
  local tool="${1}"
  local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

  if [[ "${tool}" == "my-avbroot-setup" ]]; then
    FLAG="${ADDITIONALS[MY_AVBROOT_SETUP]}"
  else
    FLAG="${ADDITIONALS[$tool_upper_case]}"
  fi

  if [[ "${FLAG}" == 'true' ]]; then
    echo 'true'
  else
    echo 'false'
  fi
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
  GRAPHENEOS[ALLOWED_SIGNERS_URL]="${GRAPHENEOS[OTA_BASE_URL]}/allowed_signers"

  # e.g.  bluejay-ota_update-2024080200
  echo -e "GrapheneOS OTA target: \`${GRAPHENEOS[OTA_TARGET]}\`\nGrapheneOS OTA URL: ${GRAPHENEOS[OTA_URL]}\n"

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

  if [ "${ADDITIONALS[ROOT]}" == 'true' ]; then
    echo "Magisk is enabled. Modifying the setup script..."
    sed -e "s/\'--rootless\'/\'--magisk\', \'${magisk_path}\',\n\t\t\'--magisk-preinit-device\', \'${MAGISK[PREINIT]}\'/" "${setup_script}" > "${setup_script}.tmp"
    mv "${setup_script}.tmp" "${setup_script}"
  else
    echo "Magisk is not enabled. Skipping..."
  fi
}

patch_ota() {
  local ota_zip="${WORKDIR}/${GRAPHENEOS[OTA_TARGET]}.zip"
  local public_key_metadata='avb_pkmd.bin'

  # Setup environment variables and paths
  env_setup

  python3 patch.py \
    --input "${ota_zip}" \
    --output "${WORKDIR}/patched_ota.zip" \
    --verify-public-key-avb "${public_key_metadata}" \
    --verify-cert-ota "${KEY[CERT_OTA]}" \
    --sign-key-avb "${KEYS[AVB]}" \
    --sign-key-ota "${KEYS[OTA]}" \
    --sign-cert-ota sign_cert.key \
    --module-custota "${WORKDIR}/custota.zip" \
    --module-msd "${WORKDIR}/msd.zip" \
    --module-bcr "${WORKDIR}/bcr.zip" \
    --module-oemunlockonboot "${WORKDIR}/oemunlockonboot.zip" \
    --module-alterinstaller "${WORKDIR}/alterinstaller.zip"

  # Deactivate the virtual environment
  deactivate

  cd -
}

env_setup() {
  afsr_setup

  local avbroot="${WORKDIR}/avbroot"
  local afsr="${WORKDIR}/afsr/target/release"

  export PATH="afsr:avbroot:$PATH"

  cd "${WORKDIR}/my-avbroot-setup"

  if [ ! -d "venv" ]; then
    python3 -m venv venv
  fi

  source venv/bin/activate

  if [[ $(pip list | grep tomlkit &> /dev/null && echo 'true' || echo 'false') == 'false' ]]; then
    echo -e "Python module \`tomlkit\` is required to run this script.\nInstalling..."
    pip3 install tomlkit
  fi
}

afsr_setup() {
  # This is necessary since the developer chose to not make releases of the tool yet
  cd "${WORKDIR}/afsr"

  if [[ $(detect_os) == 'Linux' ]]; then
    yes | apt-get update
    yes | apt-get install e2fsprogs
  elif [[ $(detect_os) == 'Mac' ]]; then
    if ! brew list e2fsprogs &> /dev/null; then
      echo "e2fsprogs is not installed. Installing..."
      brew install pkg-config e2fsprogs

      if [[ $(uname -m) == "x86_64" ]]; then
        echo '/usr/local/Cellar/e2fsprogs/1.47.1/lib/pkgconfig' >> ~/.profile
      elif [[ $(uname -m) == "arm64" ]]; then
        echo '/opt/homebrew/Cellar/e2fsprogs/1.47.1/lib/pkgconfig' >> ~/.profile
      fi

      source ~/.profile
    fi
  fi

  cargo build --release

  cd -
}

detect_os() {
  # https://stackoverflow.com/a/68706298

  unameOut=$(uname -a)
  case "${unameOut}" in
    *Microsoft*) OS="WSL" ;;  # must be first since Windows subsystem for linux will have Linux in the name too
    *microsoft*) OS="WSL2" ;; # WARNING: My v2 uses ubuntu 20.4 at the moment slightly different name may not always work
    Linux*) OS="Linux" ;;
    Darwin*) OS="Mac" ;;
    CYGWIN*) OS="Cygwin" ;;
    MINGW*) OS="Windows" ;;
    *Msys) OS="Windows" ;;
    *) OS="UNKNOWN:${unameOut}" ;;
  esac

  echo ${OS}
}
