#!/usr/bin/env bash

# ---
# LOGGING
# Provides simple, timestamped logging functions.
# Messages may contain escape sequences such as `\n`, `%b` renders them.
# ---

# Usage: log "Doing something..."
function log() {
  printf "[%s] [INFO] -- %b\n" "$(date +"%Y-%m-%d %T")" "${1}"
}

# Prints a warning message to stderr.
# Usage: warn "Something looks off."
function warn() {
  printf "[%s] [WARN] -- %b\n" "$(date +"%Y-%m-%d %T")" "${1}" >&2
}

# Prints an error message to stderr.
# Usage: error "Something went wrong."
function error() {
  printf "[%s] [ERROR] -- %b\n" "$(date +"%Y-%m-%d %T")" "${1}" >&2
}
