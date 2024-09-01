source src/declarations.sh

function get_latest_version() {
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

  if [[ GRAPHENEOS[UPDATE_TYPE] == "install" ]]; then
    echo -e "The update type is set to \`install\` which is not supported by AVBRoot.\nExiting..."
    exit 1
  fi

  GRAPHENEOS[OTA_TARGET]="${DEVICE_NAME}-${GRAPHENEOS[UPDATE_TYPE]}-${latest_grapheneos_version}"
  GRAPHENEOS[OTA_URL]="${GRAPHENEOS[OTA_BASE_URL]}/${GRAPHENEOS[OTA_TARGET]}.zip"
  
  # e.g.  bluejay-ota_update-2024080200
  echo -e "GrapheneOS OTA target: \`${GRAPHENEOS[OTA_TARGET]}\`\nGrapheneOS OTA URL: ${GRAPHENEOS[OTA_URL]}\n"

  if [[ -z "${latest_grapheneos_version}" ]]; then
    echo -e "Failed to get the latest version."
    exit 1
  fi

  if [[ -z "${VERSION[GRAPHENEOS]}" ]]; then
    VERSION[GRAPHENEOS]="${GRAPHENEOS_VERSION:-${latest_grapheneos_version}}"
  fi

  if [[ -z "${latest_magisk_version}" ]]; then
    echo -e "Failed to get the latest Magisk version."
    exit 1
  else
    VERSION[MAGISK]="${latest_magisk_version}"
  fi
}

function get() {
  local filename="${1}"
  local url="${2}"
  local signature_url="${3:-}"

  echo "Downloading \`${filename}\`..."
  if [[ "${filename}" == "my-avbroot-setup" ]]; then
    git clone "${url}" "${WORKDIR}/tools/${filename}"
  else
    if [[ "${filename}" == "magisk" ]]; then
      suffix="apk"
    else
      suffix="zip"
    fi

    curl -sL "${url}" --output "${WORKDIR}/modules/${filename}.${suffix}"

    if [[ "${filename}" != "my-avbroot-setup" ]]; then
      if [ -n "${signature_url}" ]; then
        echo "Downloading signature for \`${filename}\`..."
        curl -sL "${signature_url}" --output "${WORKDIR}/signatures/${filename}.zip.sig"
      fi

      if [[ "${filename}" == "afsr" || "${filename}" == "avbroot" || "${filename}" == "custota-tool" ]]; then
        echo -e "Extracting and granting permissions for \`${filename}\`..."
        echo N | unzip -q -o "${WORKDIR}/modules/${filename}.zip" -d "${WORKDIR}/tools/${filename}"
        chmod +x "${WORKDIR}/tools/${filename}/${filename}"

        echo -e "Cleaning up..."
        rm "${WORKDIR}/modules/${filename}.zip"
      fi
    fi
  fi
  echo -e "\`${filename}\` downloaded."
}

function download_ota() {
  local ota="${WORKDIR}/${GRAPHENEOS[OTA_TARGET]}.zip"

  if [ ! -z "${GRAPHENEOS[OTA_URL]}" ]; then
    get_latest_version
  fi

  if [ ! -f "${ota}" ]; then
    echo -e "Downloading OTA from: ${GRAPHENEOS[OTA_URL]}...\nPlease be patient while the download happens."
    curl -sL "${GRAPHENEOS[OTA_URL]}" --output ${ota}
    echo -e "OTA downloaded to: \`${ota}\`\n"
  else
    echo -e "OTA is already downloaded in: \`${ota}\`\n"
  fi
}
