source $BP_DIR/lib/binaries.sh

create_signature() {
  # Simply use package.json hash - that's all we need
  if [[ -f "$BUILD_DIR/package.json" ]]; then
    md5sum "$BUILD_DIR/package.json" 2>/dev/null | cut -d' ' -f1
  else
    echo "no-package-json"
  fi
}

save_signature() {
  create_signature > $CACHE_DIR/node/signature
  
  # Save package.json for reference
  if [[ -f "$BUILD_DIR/package.json" ]]; then
    cp "$BUILD_DIR/package.json" "$CACHE_DIR/node/package.json.cached"
  fi
}

load_signature() {
  if test -f $CACHE_DIR/node/signature; then
    cat $CACHE_DIR/node/signature
  else
    echo ""
  fi
}

get_cache_status() {
  if [ "${NODE_MODULES_CACHE:-false}" = "true" ]; then
    echo "disabled"
  elif ! test -d "${CACHE_DIR}/node/"; then
    echo "not-found"
  elif [ "$(create_signature)" != "$(load_signature)" ]; then
    echo "new-signature"
  else
    echo "valid"
  fi
}

get_cache_directories() {
  local dirs1=$(read_json "$BUILD_DIR/package.json" ".cacheDirectories | .[]?")
  local dirs2=$(read_json "$BUILD_DIR/package.json" ".cache_directories | .[]?")

  if [ -n "$dirs1" ]; then
    echo "$dirs1"
  else
    echo "$dirs2"
  fi
}

restore_default_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  if [[ -e "$cache_dir/node/node_modules" ]] && [[ "$(ls -A "$cache_dir/node/node_modules" 2>/dev/null)" ]]; then
    echo "- node_modules (cache exists)"
  else
    echo "- node_modules (cache empty, will install fresh)"
  fi
}

restore_custom_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}
  local cache_directories=("${@:3}")

  echo "Loading ${#cache_directories[@]} from cacheDirectories (package.json):"

  for cachepath in "${cache_directories[@]}"; do
    if [ -e "$build_dir/$cachepath" ]; then
      echo "- $cachepath (exists - skipping)"
    else
      if [ -e "$cache_dir/node/$cachepath" ]; then
        echo "- $cachepath"
        mkdir -p "$(dirname "$build_dir/$cachepath")"
        mv "$cache_dir/node/$cachepath" "$build_dir/$cachepath"
      else
        echo "- $cachepath (not cached - skipping)"
      fi
    fi
  done
}

clear_cache() {
  rm -rf $CACHE_DIR/node
  mkdir -p $CACHE_DIR/node
}

save_default_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  # If node_modules is a symlink to cache, no need to copy
  if [[ -L "$build_dir/node_modules" ]]; then
    echo "- node_modules (symlink - no copy needed)"
  elif [[ -e "$build_dir/node_modules" ]]; then
    echo "- node_modules"
    mkdir -p "$cache_dir/node"
    cp -a "$build_dir/node_modules" "$cache_dir/node/"
  fi
}

save_custom_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}
  local cache_directories=("${@:3}")

  echo "Saving ${#cache_directories[@]} cacheDirectories (package.json):"

  for cachepath in "${cache_directories[@]}"; do
    if [ -e "$build_dir/$cachepath" ]; then
      echo "- $cachepath"
      mkdir -p "$cache_dir/node/$cachepath"
      cp -a "$build_dir/$cachepath" "$(dirname "$cache_dir/node/$cachepath")"
    else
      echo "- $cachepath (nothing to cache)"
    fi
  done
}
