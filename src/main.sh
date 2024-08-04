#!/bin/bash

. src/util_functions.sh

main() {
  # Check for requirements
  check_dependencies
  # Patch the OTA, sign it, make a release and push it to the server
  create_and_make_release
  cleanup
}

main "$@"
