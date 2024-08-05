. src/declarations.sh

# There is no need for us to verify the signature of the tools as my-avbroot-setup
# will do it for us at patch time

verify_downloads() {
  # Verify the downloaded tools
  # If the tools are not present, exit the script
  # Else, continue with the script
  local tool="${1}"

  echo "Verifying ${tool}..."
  local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

  if [[ ! -d "${WORKDIR}/${tool}" && "${WORKDIR}/$tool}" != "magisk.apk" ]]; then
    tool="${tool}.zip"
  fi
  if [[ ! -e "${WORKDIR}/${tool}" ]]; then
    echo "Error: ${tool} not found in ${WORKDIR}"
    exit 1
  fi

  echo "All tools are verified to be existent in ${WORKDIR}."
}
