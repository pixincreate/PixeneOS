# This file consists of functions to verify the downloaded tools and signatures existence
# Verifier also looks after retries if the tool is not found
# We do not verify signatures as `my-avbroot-setup` checks on behalf of us and `magisk` do not have signature

# Source the declarations file
source src/declarations.sh

# Initialize retry count and maximum retries
RETRY_COUNT=0
MAX_RETRIES=3

# Function to look after number of times a retry has been made if the auto retry flag is enabled
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

# Function to verify the downloaded tools and signatures
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

  # Check if the tool_path has a value
  if [[ -e "${tool_path}" ]]; then
    # Check if the tool is a directory or a file
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

  # Check if signatures are present for all downloaded files except for `my-avbroot-setup` and `magisk`
  if [[ ! -n "$(ls "${WORKDIR}/signatures/"*.sig 2> /dev/null)" && "${tool}" != "my-avbrot-setup" && "${tool}" != "magisk" ]]; then
    echo -e "Error: Signature for \`${tool}\` not found in \`${WORKDIR}/signatures\`\n"
    auto_retry_check
    return $?
  fi
}
