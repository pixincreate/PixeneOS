source src/declarations.sh
source src/exchange.sh
source src/fetcher.sh
source src/verifier.sh

function check_and_download_dependencies() {
  make_directories

  # Check for Python requirements
  if ! command -v python3 &> /dev/null; then
    echo -e "Python 3 is required to run this script.\nExiting..."
    exit 1
  fi

  # Check for required tools
  # If they're present, continue with the script
  # Else, download them by checking version from declarations
  local tools=("avbroot" "afsr" "alterinstaller" "custota" "custota-tool" "msd" "bcr" "oemunlockonboot" "my-avbroot-setup")
  for tool in "${tools[@]}"; do
    local flag=$(flag_check "${tool}")
    if [[ "${flag}" == 'false' ]]; then
      echo -e "\`${tool}\` is **NOT** enabled in the configuration.\nSkipping...\n"
      continue
    fi

    local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

    if [ -f "${WORKDIR}/modules/${tool}.zip" ]; then
      echo -e "\`${tool}.zip\` file already exists in \`${WORKDIR}/modules\`."
      continue
    fi

    if [ -f "${WORKDIR}/tools/${tool}" ]; then
      echo -e "\`${tool}\` file already exists in \`${WORKDIR}/tools\`."
      continue
    fi

    # If neither condition is met, download dependencies
    download_dependencies "${tool}"

    verify_downloads "${tool}"
  done

  if [[ "${ADDITIONALS[ROOT]}" == 'true' ]]; then
    get "magisk" "${MAGISK[URL]}/releases/download/canary-${VERSION[MAGISK]}/app-release.apk"
    verify_downloads "magisk.apk"
  fi
}

function flag_check() {
  local tool="${1}"
  local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

  if [[ "${tool}" == "my-avbroot-setup" ]]; then
    FLAG="${ADDITIONALS[MY_AVBROOT_SETUP]}"
  elif [[ "${tool}" == "custota-tool" ]]; then
    FLAG="${ADDITIONALS[CUSTOTA_TOOL]}"
  else
    FLAG="${ADDITIONALS[$tool_upper_case]}"
  fi

  if [[ "${FLAG}" == 'true' ]]; then
    echo 'true'
  else
    echo 'false'
  fi
}

function create_and_make_release() {
  download_ota
  create_ota
  export_necessities
}

function create_ota() {
  [[ "${CLEANUP}" != 'true' ]] && trap cleanup EXIT ERR

  # Generate output file names
  generate_ota_info
  # Setup environment variables and paths
  env_setup
  # Patch OTA with avbroot and afsr by leveraging my-avbroot-setup
  patch_ota
}

function cleanup() {
  if [[ "${CLEANUP}" != 'true' ]]; then
    echo -e "Cleanup is disabled. Exiting...\n"
    return
  fi

  echo "Cleaning up..."
  rm -rf "${WORKDIR}"
  unset "${KEYS[@]}"
  echo "Cleanup complete."
}

# Generate the AVB and OTA signing keys.
# Has to be called manually.
function generate_keys() {
  local public_key_metadata='avb_pkmd.bin'

  # Generate the AVB and OTA signing keys
  avbroot key generate-key -o "${KEYS[AVB]}"
  avbroot key generate-key -o "${KEYS[OTA]}"

  # Convert the public key portion of the AVB signing key to the AVB public key metadata format
  # This is the format that the bootloader requires when setting the custom root of trust
  avbroot key extract-avb -k "${KEYS[AVB]}" -o "${public_key_metadata}"

  # Generate a self-signed certificate for the OTA signing key
  # This is used by recovery to verify OTA updates when sideloading
  avbroot key generate-cert -k "${KEYS[OTA]}" -o "${KEYS[CERT_OTA]}"

  # Convert the keys to base64 which can be used in CI/CD pipeline environment
  base64_encode
}

function patch_ota() {
  if [[ "${INTERACTIVE_MODE}" != 'true' ]]; then
    base64_decode
  fi

  local ota_zip="${WORKDIR}/${GRAPHENEOS[OTA_TARGET]}"
  local pkmd="${KEYS[PKMD]}"
  local grapheneos_pkmd="${WORKDIR}/extracted/avb_pkmd.bin"
  local grapheneos_otacert="${WORKDIR}/extracted/ota/META-INF/com/android/otacert"
  local my_avbroot_setup="${WORKDIR}/tools/my-avbroot-setup"

  # Activate the virtual environment
  if [ -z "${VIRTUAL_ENV}" ]; then
    enable_venv
  fi

  if [[ ! -e "${grapheneos_pkmd}" || ! -e "${grapheneos_otacert}" ]]; then
    echo "Extracting official keys..."
    extract_official_keys
  fi

  # At present, the script lacks the ability to disable certain modules.
  # Everything is hardcoded to be enabled by default.
  if ls "${ota_zip}.patched*.zip" 1> /dev/null 2>&1; then
    echo -e "File ${ota_zip}.pathed.zip already exists in local. Patch skipped."
  else
    echo -e "Patching OTA..."
    local args=()

    args+=("--input" "${ota_zip}.zip")
    args+=("--output" "${OUTPUT[PATCHED_OTA]}")

    args+=("--verify-public-key-avb" "${grapheneos_pkmd}")
    args+=("--verify-cert-ota" "${grapheneos_otacert}")

    args+=("--sign-key-avb" "${KEYS[AVB]}")
    args+=("--sign-key-ota" "${KEYS[OTA]}")
    args+=("--sign-cert-ota" "${KEYS[CERT_OTA]}")

    args+=("--module-custota" "${WORKDIR}/modules/custota.zip")
    args+=("--module-msd" "${WORKDIR}/modules/msd.zip")
    args+=("--module-bcr" "${WORKDIR}/modules/bcr.zip")
    args+=("--module-oemunlockonboot" "${WORKDIR}/modules/oemunlockonboot.zip")
    args+=("--module-alterinstaller" "${WORKDIR}/modules/alterinstaller.zip")

    args+=("--module-custota-sig" "${WORKDIR}/signatures/custota.zip.sig")
    args+=("--module-msd-sig" "${WORKDIR}/signatures/msd.zip.sig")
    args+=("--module-bcr-sig" "${WORKDIR}/signatures/bcr.zip.sig")
    args+=("--module-oemunlockonboot-sig" "${WORKDIR}/signatures/oemunlockonboot.zip.sig")
    args+=("--module-alterinstaller-sig" "${WORKDIR}/signatures/alterinstaller.zip.sig")

    python ${my_avbroot_setup}/patch.py "${args[@]}"
  fi

  # Deactivate the virtual environment
  deactivate
}

function detect_os() {
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

function my_avbroot_setup() {
  local setup_script="${WORKDIR}/tools/my-avbroot-setup/patch.py"
  local magisk_path="${WORKDIR}/modules/magisk.apk"
  local location_path="${DOMAIN}/${USER}/${REPOSITORY}/releases/download/${VERSION[GRAPHENEOS]}/${OUTPUT[PATCHED_OTA]}"

  # Add support to pass env-vars to the setup script
  echo "Running script modifications..."
  sed -i -e "/'avbroot', 'ota', 'patch',/a \\
  \t\t'--pass-avb-env-var', 'PASSPHRASE_AVB',\\
  \t\t'--pass-ota-env-var', 'PASSPHRASE_OTA'," "${setup_script}"

  sed -i -e "/custota-tool', 'gen-csig',/a \\
  \t\t'--passphrase-env-var', 'PASSPHRASE_OTA'," "${setup_script}"

  sed -i -e "s|generate_update_info(update_info, args.output.name)|generate_update_info(update_info, '${location_path}')|" "${setup_script}"

  if [[ "${ADDITIONALS[ROOT]}" == 'true' ]]; then
    echo -e "Magisk is enabled. Modifying the setup script...\n"
    sed -i -e "s|'--rootless'|'--magisk', '${magisk_path}',\\
    \t\t'--magisk-preinit-device', '${MAGISK[PREINIT]}'|" "${setup_script}"
  else
    echo -e "Magisk is not enabled. Skipping...\n"
  fi
}

function env_setup() {
  my_avbroot_setup

  local avbroot="${WORKDIR}/tools/avbroot"
  local afsr="${WORKDIR}/tools/afsr"
  local custota_tool="${WORKDIR}/tools/custota-tool"
  local my_avbroot_setup="${WORKDIR}/tools/my-avbroot-setup"

  if ! command -v avbroot &> /dev/null && ! command -v afsr &> /dev/null && ! command -v custota-tool &> /dev/null; then
    export PATH="$(realpath ${afsr}):$(realpath ${avbroot}):$(realpath ${custota_tool}):$PATH"
  fi

  enable_venv

  if [[ $(pip list | grep tomlkit &> /dev/null && echo 'true' || echo 'false') == 'false' ]]; then
    echo -e "Python module \`tomlkit\` is required to run this script.\nInstalling..."
    pip3 install tomlkit
  fi
}

function enable_venv() {
  local dir_path='' # Default value is empty string
  local base_path=$(basename "$(pwd)")
  local venv_path=''

  # Check presence of venv
  if [[ "${base_path}" == "my-avbroot-setup" ]]; then
    if [ ! -d "venv" ]; then
      echo -e "Virtual environment not found. Creating..."
      python3 -m venv venv
    fi
  else
    echo -e "The script is not run from the \`my-avbroot-setup\` directory.\nSearching for the directory..."
    dir_path=$(find . -type d -name "my-avbroot-setup" -print -quit)
    if [ ! -d "${dir_path}/venv" ]; then
      echo -e "Virtual environment not found in path \`${dir_path}\`. Creating..."
      python3 -m venv "${dir_path}/venv"
    fi
  fi

  if [ -n "${dir_path}" ]; then
    venv_path="${dir_path}/venv/bin/activate"
  else
    venv_path="venv/bin/activate"
  fi

  # Ensure venv_path is set correctly
  if [ -f "${venv_path}" ]; then
    source "${venv_path}"
  else
    echo -e "Virtual environment activation script not found at \`${venv_path}\`."
  fi
}

function url_constructor() {
  local repository="${1}"
  local user='chenxiaolong'
  INTERACTIVE_MODE="${2:-true}"

  local repository_upper_case=$(echo "${repository}" | tr '[:lower:]' '[:upper:]')

  echo -e "Constructing URL for \`${repository}\` as \`${repository}\` is non-existent at \`${WORKDIR}\`..."
  if [[ "${repository}" == "my-avbroot-setup" ]]; then
    URL="${DOMAIN}/${user}/${repository}"
  else
    if [[ "${repository}" == "afsr" || "${repository}" == "avbroot" || "${repository}" == "custota-tool" ]]; then
      local suffix="${ARCH}"
    else
      local suffix="release"
    fi

    if [[ "${repository}" == "custota-tool" ]]; then
      local download_page="${DOMAIN}/${user}/Custota/releases/download"
      local version="v${VERSION[CUSTOTA]}"
      local application="${repository}-${VERSION[CUSTOTA]}-${suffix}.zip"
    else
      local download_page="${DOMAIN}/${user}/${repository}/releases/download"
      local version="v${VERSION[${repository_upper_case}]}"
      local application="${repository}-${VERSION[${repository_upper_case}]}-${suffix}.zip"
    fi

    URL="${download_page}/${version}/${application}"
    SIGNATURE_URL="${download_page}/${version}/${application}.sig"
  fi

  echo -e "URL for \`${repository}\`: ${URL}"

  if [[ "${INTERACTIVE_MODE}" == 'true' ]]; then
    if [[ -e "${WORKDIR}/tools/${repository}" || -e "${WORKDIR}/modules/${repository}.zip" || -e "${WORKDIR}/signatures/${repository}.zip.sig" ]]; then
      echo -n "Warning: \`${repository}\` already exists in \`${WORKDIR}\`\nOverwrite? (y/n) [default: yes]: "
      read -r confirm
      confirm=${confirm:-"yes"}
      if [[ $confirm =~ ^[yY](es|ES)?$ ]]; then
        echo "Removing existing files..."
        rm -rf "${WORKDIR}/tools/${repository}" "${WORKDIR}/modules/${repository}.zip" "${WORKDIR}/signatures/${repository}.zip.sig"
      else
        echo "Aborted."
      fi
    fi
  fi

  get "${repository}" "${URL}" "${SIGNATURE_URL}"
}

function download_dependencies() {
  local tool="${1}"
  INTERACTIVE_MODE='false'

  if type url_constructor &> /dev/null; then
    url_constructor "${tool}" "${INTERACTIVE_MODE}"
  else
    echo -e "Error: \`url_constructor\` function is not defined."
    exit 1
  fi
}

function extract_official_keys() {
  # https://github.com/chenxiaolong/my-avbroot-setup/issues/1#issuecomment-2270286453
  # AVB: Extract vbmeta.img, run avbroot avb info -i vbmeta.img.
  #   The public_key field is avb_pkmd.bin encoded as hex.
  #   Verify that the key is official by comparing its sha256 checksum with grapheneos.org/articles/attestation-compatibility-guide.
  # OTA: Extract META-INF/com/android/otacert from the OTA.
  #   (Or from otacerts.zip inside system.img or vendor_boot.img. All 3 files are identical.)
  local ota_zip="${WORKDIR}/${GRAPHENEOS[OTA_TARGET]}.zip"

  # Extract OTA
  avbroot ota extract \
    --input "${ota_zip}" \
    --directory "${WORKDIR}/extracted/extracts" \
    --all

  # Extract vbmeta.img
  # To verify, execute sha256sum avb_pkmd.bin in terminal
  # compare the output with base16-encoded verified boot key fingerprints
  # mentioned at https://grapheneos.org/articles/attestation-compatibility-guide for the respective device
  avbroot avb info -i "${WORKDIR}/extracted/extracts/vbmeta.img" \
    | grep 'public_key' \
    | sed -n 's/.*public_key: "\(.*\)".*/\1/p' \
    | tr -d '[:space:]' | xxd -r -p > "${WORKDIR}/extracted/avb_pkmd.bin"

  # Extract META-INF/com/android/otacert from OTA or otacerts.zip from either vendor_boot.img or system.img
  unzip "${ota_zip}" -d "${WORKDIR}/extracted/ota"
}

function dirty_suffix() {
  if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    echo "-dirty"
  else
    echo ""
  fi
}

function make_directories() {
  mkdir -p \
    "${WORKDIR}" \
    "${WORKDIR}/.keys" \
    "${WORKDIR}/extracted/extracts" \
    "${WORKDIR}/extracted/ota" \
    "${WORKDIR}/modules" \
    "${WORKDIR}/signatures" \
    "${WORKDIR}/tools"
}

function generate_ota_info() {
  local flavor=$([[ ${ADDITIONALS[ROOT]} == 'true' ]] && echo "magisk-${VERSION[MAGISK]}" || echo "rootless")
  OUTPUT[PATCHED_OTA]="${DEVICE_NAME}-${VERSION[GRAPHENEOS]}-${flavor}-$(git rev-parse --short HEAD)$(dirty_suffix).zip"
}

function export_necessities() {
  # since exporting cannot be done for associative arrays, we only export the necessities that allows deployment to happen
  echo "GRAPHENEOS_OTA_TARGET=${GRAPHENEOS[OTA_TARGET]}" >> .env
  echo "GRAPHENEOS_VERSION=${VERSION[GRAPHENEOS]}" >> .env
  echo "OUTPUT_PATCHED_OTA=${OUTPUT[PATCHED_OTA]}" >> .env
  echo "WORKDIR=${WORKDIR}" >> .env
}
