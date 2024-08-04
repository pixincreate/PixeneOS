. ./declarations.sh

# There is no need for us to verify the signature of the tools as my-avbroot-setup
# will do it for us at patch time

verify_downloads() {
  # Verify the downloaded tools
  # If the tools are not present, exit the script
  # Else, continue with the script
  verify
}

verify() {
  echo "Verifying ${tool}..."
  local tools=("avbroot" "custota" "msd" "bcr" "oemunlockonboot")
  for tool in "${tools[@]}"; do
    if [ ! -e "${WORKDIR}/${tool}" ]; then
      echo "Error: ${tool} not found in ${WORKDIR}"
      exit 1
    fi
    if [ ! -e "my-avbroot-setup" ]; then
      echo "Error: \`my-avbroot-setup\` not found in ${WORKDIR}"
      exit 1
    fi
    if [ ! -e "afsr" ]; then
      echo "Error: \`afsr\` not found in ${WORKDIR}"
      exit 1
    fi
    if [ ! -e "${tool}.sig" ]; then
      echo "Error: Signature for ${tool} not found in ${WORKDIR}"
      exit 1
    fi
  done
  if [ "${ADDITIONALS[root]}" ]; then
    if [ ! -e "${WORKDIR}/magisk" ]; then
      echo "Error: Magisk not found in ${WORKDIR}"
      exit 1
    fi
  fi
  echo "All tools are verified."
}
