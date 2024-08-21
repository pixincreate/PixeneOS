source src/declarations.sh

function base64_encode() {
  local success_status=false
  echo -e "\nEncoding keys to base64..."

  KEYS[AVB_BASE64]=$(base64 -w0 "${KEYS[AVB]}") && echo "KEYS[AVB_BASE64]=\`${KEYS[AVB_BASE64]}\`" && success_status=true
  KEYS[OTA_BASE64]=$(base64 -w0 "${KEYS[OTA]}") && echo "KEYS[OTA_BASE64]=\`${KEYS[OTA_BASE64]}\`" && success_status=true
  KEYS[CERT_OTA_BASE64]=$(base64 -w0 "${KEYS[CERT_OTA]}") && echo "KEYS[CERT_OTA_BASE64]=\`${KEYS[CERT_OTA_BASE64]}\`" && success_status=true

  if [[ "${success_status}" == true ]]; then
    export "${KEYS[AVB_BASE64]}}" "${KEYS[OTA_BASE64]}" "${KEYS[CERT_OTA_BASE64]}"
    echo -e "Encoded keys to base64.\n"
  else
    echo "Failed to encode keys to base64.\n"
    exit 1
  fi
}

function base64_decode() {
  local success_status=false
  echo -e "\nDecoding keys from base64..."

  KEYS[AVB_BASE64]="${KEYS_AVB_BASE64:-${KEYS[AVB_BASE64]}}"
  KEYS[CERT_OTA_BASE64]="${KEYS_CERT_OTA_BASE64:-${KEYS[CERT_OTA_BASE64]}}"
  KEYS[OTA_BASE64]="${KEYS_OTA_BASE64:-${KEYS[OTA_BASE64]}}"

  local keys=("AVB_BASE64" "CERT_OTA_BASE64" "OTA_BASE64")
  for key in "${keys[@]}"; do
    local base64_key="${KEYS[$key]}"

    if [[ -n "${base64_key}" ]]; then
      # Generate output file name based on key name
      local output_file="${WORKDIR}/keys/${KEYS[$(echo ${key} | sed 's/_BASE64$//')]}"

      # Decode bas64 and write to a file
      echo "${base64_key}" | base64 --decode > "${output_file}" 2> /dev/null

      if [[ $? -ne 0 ]]; then
        echo "Error decoding base64 for ${key}"
        success_status=false
      else
        # Decodes ${key} to ${output_file}"
        KEYS[$(echo ${key} | sed 's/_BASE64$//')]="${output_file}"
        success_status=true
      fi
    else
      echo "No base64 data found for ${key}"
      success_status=false
    fi
  done

  if [[ "${success_status}" == true ]]; then
    echo -e "Decoded keys from base64.\n"
  else
    echo "Failed to decode keys from base64.\n"
    exit 1
  fi
}
