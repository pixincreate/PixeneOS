source src/declarations.sh

# Initialize retry count
RETRY_COUNT=0
MAX_RETRIES=3

function auto_retry_check() {
  if [[ "${ADDITIONALS[RETRY]}" == "true" ]]; then
    if ((RETRY_COUNT < MAX_RETRIES)); then
      RETRY_COUNT=$((RETRY_COUNT + 1))
      echo -e "Auto retry is enabled. Retrying (${RETRY_COUNT}/${MAX_RETRIES})...\n"
      RETRY="true"
      return 0
    else
      echo -e "Maximum retry limit reached. Exiting...\n"
      exit 1
    fi
  else
    echo -e "Auto retry is not enabled. Exiting...\n"
    exit 1
  fi
}

function verify_downloads() {
  # Verify the downloaded tools
  # If the tools are not present, exit the script
  # Else, continue with the script
  local tool="${1}"
  local tool_path=""

  echo "Verifying \`${tool}\`..."

  if [[ -f "${WORKDIR}/modules/${tool}.zip" ]] && [ "${tool}" != "magisk" ]; then
    tool_path="${WORKDIR}/modules/${tool}.zip"
  elif [[ -f "${WORKDIR}/modules/${tool}.apk" ]]; then
    tool_path="${WORKDIR}/modules/${tool}.apk"
  elif [[ -d "${WORKDIR}/tools/${tool}" ]]; then
    tool_path="${WORKDIR}/tools/${tool}"
  fi

  if [[ -e "${tool_path}" ]]; then
    if [[ -d "${tool_path}" ]]; then
      echo -e "Tool ${tool} is a directory in \`${WORKDIR}/tools/\`. Verified.\n"
    elif [[ -f "${tool_path}" ]]; then
      echo -e "Module \`${tool_path}\` found and verified in \`${WORKDIR}/modules/\`.\n"
    fi
    RETRY="false"
  else
    echo -e "Error: \`${tool}\` not found in \`${WORKDIR}\`\n"
    auto_retry_check
    return $?
  fi

  if [[ ! -n "$(ls "${WORKDIR}/signatures/"*.sig 2> /dev/null)" && "${tool}" != "my-avbrot-setup" && "${tool}" != "magisk" ]]; then
    echo -e "Error: Signature for \`${tool}\` not found in \`${WORKDIR}/signatures\`\n"
    auto_retry_check
    return $?
  fi
}
