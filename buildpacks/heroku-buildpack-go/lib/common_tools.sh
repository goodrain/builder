#!/bin/bash

# Ensure jq is installed.
# ensureInPath "jq-linux64" "${cache}/.jq/bin"

# Use bins from pre-compile/bin. Like jq
addToPATH /tmp/pre-compile/bin
info "Use Local jq"

# Ensure we have a copy of the stdlib. Use Local stdlib.v8
STDLIB_DIR=${buildpack}/lib
BPLOG_PREFIX="buildpack.go"

source_stdlib() {
  info "Use Local stdlib.sh.v8"
  chmod a+x ${STDLIB_DIR}/stdlib.sh.v8
  source "${STDLIB_DIR}/stdlib.sh.v8"
}
