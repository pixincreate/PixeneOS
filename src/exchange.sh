source src/declarations.sh

function base64_encode() {
  echo -e "Encoding keys to base64..."

  KEYS[AVB_BASE64]=$(base64 -w0 "${KEYS[AVB]}") && echo "KEYS[AVB_BASE64]=${KEYS[AVB_BASE64]}"
  KEYS[OTA_BASE64]=$(base64 -w0 "${KEYS[OTA]}") && echo "KEYS[OTA_BASE64]=${KEYS[OTA_BASE64]}"
  KEYS[CERT_OTA_BASE64]=$(base64 -w0 "${KEYS[CERT_OTA]}") && echo "KEYS[CERT_OTA_BASE64]=${KEYS[CERT_OTA_BASE64]}"

  export "${KEYS[AVB_BASE64]}}" "${KEYS[OTA_BASE64]}" "${KEYS[CERT_OTA_BASE64]}"

  echo -e "Encoded keys to base64."
}

function base64_decode() {
  echo -e "Decoding keys from base64..."

  if [[ -n "${KEYS[AVB_BASE64]}" ]]; then
    echo "${KEYS[AVB_BASE64]}" | base64 --decode > ".tmp/${KEYS[AVB]}"
  fi
  if [[ -n "${KEYS[CERT_OTA_BASE64]}" ]]; then
    echo "${KEYS[CERT_OTA_BASE64]}" | base64 --decode > ".tmp/${KEYS[CERT_OTA]}"
  fi
  if [[ -n "${KEYS[OTA_BASE64]}" ]]; then
    echo "${KEYS[OTA_BASE64]}" | base64 --decode > ".tmp/${KEYS[OTA]}"
  fi

  echo -e "Decoded keys from base64."
}
