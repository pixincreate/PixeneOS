. src/declarations.sh

# There is no need for us to verify the signature of the tools as my-avbroot-setup
# will do it for us at patch time

function verify_downloads() {
  # Verify the downloaded tools
  # If the tools are not present, exit the script
  # Else, continue with the script
  local tool="${1}"

  echo "Verifying \`${tool}\`..."
  local tool_upper_case=$(echo "${tool}" | tr '[:lower:]' '[:upper:]')

  # Check if the file exists in the modules directory and is not a directory
  if [[ -f "${WORKDIR}/modules/${tool}.zip" && ! -d "${WORKDIR}/modules/${tool}" ]]; then
    base_name=$(basename "${WORKDIR}/modules/${tool}")

    if [[ "${base_name}" != "magisk.apk" || "${base_name}" =~ \.zip$ ]]; then
      tool="${tool}.zip"
    fi
  fi

  if [[ -d "${WORKDIR}/${tool}" ]]; then
    echo -e "Tool ${tool} is a directory in \`${WORKDIR}\`. Verified.\n"
  elif [[ -f "${WORKDIR}/modules/${tool}" ]]; then
    echo -e "Tool \`${tool}\` found and verified.\n"
  else
    echo -e "Error: \`${tool}\` not found in \`${WORKDIR}\`\nExiting...\n"
    exit 1
  fi
}
