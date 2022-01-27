#!/bin/bash

# Ensure jq is installed.
# ensureInPath "jq-linux64" "${cache}/.jq/bin"

# Use bins from pre-compile/bin. Like jq
# addToPATH /tmp/pre-compile/bin
# ln -s /tmp/pre-compile/bin/jq-${ARCH} /tmp/pre-compile/bin/jq 
# info "Use Local jq"
# define jq in pre-compoile

# Ensure we have a copy of the stdlib. Use Local stdlib.v8
STDLIB_DIR=${buildpack}/lib
BPLOG_PREFIX="buildpack.go"

source_stdlib() {
  info "Use Local stdlib.sh.v8"
  chmod a+x ${STDLIB_DIR}/stdlib.sh.v8
  source "${STDLIB_DIR}/stdlib.sh.v8"
}
