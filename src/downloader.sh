. src/declarations.sh

url_constructor() {
  local repository="${1}"
  local automated="${2:-false}"
  local user='chenxiaolong'
  # local arch="x86_64-unknown-linux-gnu" # for Linux
  local arch="universal-apple-darwin" # for macOS
  # local arch="x86_64-pc-windows-msvc" # for Windows

  local repository_upper_case=$(echo "${repository}" | tr '[:lower:]' '[:upper:]')

  echo -e "Constructing URL for \`${repository}\` as \`${repository}\` is non-existent at \`${WORKDIR}\`..."
  if [[ "${repository}" == "afsr" || "${repository}" == "my-avbroot-setup" ]]; then
    URL="${DOMAIN}/${user}/${repository}"
  else
    if [[ "${repository}" == "avbroot" || "${repository}" == "custota" ]]; then
      if [[ "${repository}" == "custota" ]]; then
        local file_addition="-tool"
      fi
      local suffix="${arch}"
    else
      local suffix="release"
    fi

    URL="${DOMAIN}/${user}/${repository}/releases/download/v${VERSION[${repository_upper_case}]}/${repository}${file_addition}-${VERSION[${repository_upper_case}]}-${suffix}.zip"
    SIGNATURE_URL="${DOMAIN}/${user}/${repository}/releases/download/v${VERSION[${repository_upper_case}]}/${repository}${file_addition}-${VERSION[${repository_upper_case}]}-${suffix}.zip.sig"
  fi

  echo -e "URL for \`${repository}\`: ${URL}"

  if [[ "${automated}" == 'false' ]]; then
    if [[ -e "${WORKDIR}/${repository}" ]]; then
      echo -n "Warning: \`${repository}\` already exists in \`${WORKDIR}\`\nOverwrite? (y/n): "
      read confirm
      if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        rm -rf "${WORKDIR}/${repository}"
      fi
    fi
  fi
  get "${repository}" "${URL}" "${SIGNATURE_URL}"
}

get() {
  local filename="${1}"
  local url="${2}"
  local signature_url="${3}"

  echo "Downloading \`${filename}\`..."
  if [[ "${filename}" == "my-avbroot-setup" || "${filename}" == "afsr" ]]; then
    git clone "${url}" "${WORKDIR}/${filename}"
  else
    if [[ "${filename}" == "magisk" ]]; then
      suffix="apk"
    else
      suffix="zip"
    fi
    curl -sL "${url}" --output "${WORKDIR}/${filename}.${suffix}"

    if [[ "${filename}" == "avbroot" ]]; then
      # I do not find the need to verify signatures for tools other than AVBRoot
      curl -sL "${signature_url}" --output "${WORKDIR}/${filename}.zip.sig"

      echo -e "Extracting and granting permissions for \`${filename}\`..."
      echo N | unzip -q "${WORKDIR}/${filename}.zip" -d "${WORKDIR}/${filename}"
      chmod +x "${WORKDIR}/${filename}/${filename}"

      echo -e "Cleaning up..."
      rm "${WORKDIR}/${filename}.zip"
    fi
  fi
  echo -e "\`${filename}\` downloaded to: \`${WORKDIR}/${filename}\`"
}

download_dependencies() {
  local tool="${1}"
  local automated='true'

  if type url_constructor &> /dev/null; then
    url_constructor "${tool}" "${automated}"
  else
    echo "Error: url_constructor function is not defined."
    exit 1
  fi

}

download_ota() {
  local ota="${WORKDIR}/${GRAPHENEOS[OTA_TARGET]}.zip"

  if [ -z "${ota}" ]; then
    echo -e "Downloading OTA from: $GRAPHENEOS[OTA_URL]...\nPlease be patient while the download happens."
    curl -sL "${GRAPHENEOS[OTA_URL]}" --output ${ota}
    echo -e "OTA downloaded to: ${ota}"
  fi
  if [ -z "allowed_signers"]; then
    echo -e "Downloading factory images public key from: $GRAPHENEOS[ALLOWED_SIGNERS_URL]...\nPlease be patient while the download happens."
    curl -sL "${GRAPHENEOS[ALLOWED_SIGNERS_URL]}" --output ${WORKDIR}/allowed_signers
    echo -e "Factory images public key has been downloaded to: ${WORKDIR}/allowed_signers"
  fi
}
