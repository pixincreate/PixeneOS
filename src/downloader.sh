. ./declarations.sh

download_helper() {
  local filename="${1}"
  local extension="${2}"
  local URL="${3}"

  if [ -e "${WORKDIR/avbroot/}" ]; then
    echo "Downloading ${filename}${extension}..."
    curl -sL "${URL}" --output "${WORKDIR}/${filename}${extension}"
    echo "${filename} downloaded to: ${WORKDIR}/${filename}${extension}"

    if [[ "${extension}" == "*.zip" ]]; then
      echo "Extracting ${filename}${extension}..."
      echo N | unzip -q "${WORKDIR}/${filename}${extension}" -d "${WORKDIR}"
      chmod +x "${WORKDIR}/${filename}"
      echo "${filename}${extension} extracted to: ${WORKDIR}/${filename}"

      rm "${WORKDIR}/${filename}${extension}"
    fi
  else
    echo "${filename} is already installed in: ${WORKDIR}"
  fi
}

download() {
  if [ ADDITIONALS[root] ]; then
    # This downloads an APK file
    download_helper "magisk" ".apk" "${MAGISK[URL]}"
  fi

  # Iterate over each repository
  for REPOSITORY in ${AVBROOT[REPOSITORIES]}; do

    # Retrieve the flag for the current repository directly
    if [[ "${REPOSITORY}" == "my-avbroot-setup" ]]; then
      FLAG="${ADDITIONALS[my_avbroot_setup]}"
    else
      FLAG="${ADDITIONALS[$REPOSITORY]}"
    fi

    # Handle case where the flag might not be set or missing
    if [[ -z "$FLAG" ]]; then
      echo "Warning: No flag found for repository '${REPOSITORY}' in ADDITIONALS array. Skipping."
      continue
    fi

    # Check if the flag is set to 'true'
    if [[ "$FLAG" == "true" ]]; then
      if [[ "${REPOSITORY}" == "avbroot" ]]; then
        download_helper "avbroot" ".zip" "${AVBROOT[URL]}"
      else
        URL="${DOMAIN}/${AVBROOT[USER]}/${REPOSITORY}"
        download_helper "${REPOSITORY}" ".zip" "${URL}"
      fi
    fi
  done
}
