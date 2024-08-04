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
    if [ ! -e "${WORKDIR}/${tool}" ]; then
      echo "Error: ${tool} not found in ${WORKDIR}"
      exit 1
    fi
  done
  if [ "${ADDITIONALS[root]}" ]; then
    if [ ! -e "${WORKDIR}/magisk" ]; then
      echo "Error: Magisk not found in ${WORKDIR}"
      exit 1
    fi
  fi
  echo "All tools are verified to be existent in ${WORKDIR}."
}
