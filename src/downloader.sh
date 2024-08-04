. ./declarations.sh

url_constructor() {
  local user='chenxiaolong'
  local arch="x86_64-unknown-linux-gnu"
  local declare -A VERSION

  local repositories="avbroot afsr custota msd bcr oemunlockonboot my-avbroot-setup"

  VERSION[AVBROOT]="3.4.1"
  VERSION[CUSTOTA]="4.7"
  VERSION[MSD]="1.1"
  VERSION[BCR]="1.69"
  VERSION[OEMUNLOCKONBOOT]="1.1"

  for repository in ${repositories}; do
    if [[ "${repository}" == "afsr" || "${repository}" == "my-avbroot-setup" ]]; then
      URL="${DOMAIN}/${user}/${repository}"
    else

      if [[ "${repository}" == "avbroot" || "${repository}" == "custota" ]]; then
        local suffix="${arch}"
      else
        local suffix="release"
      fi

      repository=$(echo "$repository" | tr '[:lower:]' '[:upper:]')
      URL="${DOMAIN}/${user}/${repository}/releases/download/v${VERSION[${repository}]}/${repository}-${VERSION[${repository}]}-${suffix}.zip"
    fi

    if [[ "${REPOSITORY}" == "my-avbroot-setup" ]]; then
      FLAG="${ADDITIONALS[my_avbroot_setup]}"
    else
      FLAG="${ADDITIONALS[$REPOSITORY]}"
    fi
    if [[ "${FLAG}" == 'true' ]]; then
      download "${repository}" "${URL}"
    fi
  done
}

download() {
  local repository="${1}"
  local URL="${2}"

  get_latest_version

  if [ "${ADDITIONALS[root]}" ]; then
    get "magisk" "${MAGISK[URL]}"
  fi

  get "${repository}" "${URL}"
}

get() {
  local filename="${1}"
  local url="${2}"

  if [ -e "${WORKDIR}/${filename}" ]; then
    echo "${filename} is already installed in: ${WORKDIR}"
  else
    echo "Downloading ${filename}..."
    if [[ "${filename}" == "my-avbroot-setup" || "${filename}" == "afsr" ]]; then
      git clone "${url}" "${WORKDIR}/${filename}"
    else
      curl -sL "${url}" --output "${WORKDIR}/${filename}"

      echo N | unzip -q "${WORKDIR}/${filename}.zip" -d "${WORKDIR}"

      chmod +x "${WORKDIR}/${filename}"
      rm "${WORKDIR}/${filename}.zip"
    fi
    echo "${filename} downloaded to: ${WORKDIR}/${filename}"
  fi
}

download_dependencies() {
  # Download the required tools
  # If the tools are already present, skip the download
  # Else, download them
  url_constructor
}

download_ota() {
  local ota_location="${WORKDIR}/${OTA_TARGET}.zip"

  if [ -z "${ota_location}" ]; then
    echo "Downloading OTA from: $GRAPHENEOS[OTA_URL]"
    curl -sL "${GRAPHENEOS[OTA_URL]}" --output ${ota_location}
    echo "OTA downloaded to: ${ota_location}"
  fi
}
