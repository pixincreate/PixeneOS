. src/declarations.sh

# There is no need for us to verify the signature of the tools as my-avbroot-setup
# will do it for us at patch time

verify_downloads() {
  # Verify the downloaded tools
  # If the tools are not present, exit the script
  # Else, continue with the script

  echo "Verifying ${tool}..."
  local tools=("avbroot" "afsr" "my-avbroot-setup" "custota" "msd" "bcr" "oemunlockonboot")
  for tool in "${tools[@]}"; do
    local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

    if [[ "${tool}" == "my-avbroot-setup" ]]; then
      FLAG="${ADDITIONALS[MY_AVBROOT_SETUP]}"
    else
      FLAG="${ADDITIONALS[$tool_upper_case]}"
    fi

    if [[ "${FLAG}" == 'true' ]]; then
      if [[ ! -d "${WORKDIR}/${tool}" ]]; then
        tool="${tool}.zip"
      fi
      if [[ ! -e "${WORKDIR}/${tool}" ]]; then
        echo "Error: ${tool} not found in ${WORKDIR}"
        exit 1
      fi
    fi
  done

  if [ "${ADDITIONALS[ROOT]}" == 'true' ]; then
    echo "Verifying Magisk..."
    if [ ! -e "${WORKDIR}/magisk.apk" ]; then
      echo "Error: Magisk not found in ${WORKDIR}"
      exit 1
    fi
  fi
  echo "All tools are verified to be existent in ${WORKDIR}."
}
