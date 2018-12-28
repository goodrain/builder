#!/bin/bash 
set -eo pipefail

[ "$DEBUG" ] && set -x

if [[ -f /etc/environment_proxy ]]; then
    source /etc/environment_proxy
fi

# Determine the first parameter to determine the path of the slug package
if [[ "$1" == "-" ]]; then
    slug_file="$1"
elif [[ "$1" == "local" ]];then
    if [ -n "$SLUG_VERSION" ];then
        filename=$SLUG_VERSION
    else
        filename=`date +%Y%m%d%H%M%S`
    fi
    slug_file=/tmp/slug/$filename.tgz
elif [[ "$1" == "debug" ]];then
    /bin/bash
elif [[ "$1" == "version" ]];then
    echo $RELEASE_DESC
    exit 0
else 
    slug_file=/tmp/slug.tgz
    if [[ "$1" ]]; then
        put_url="$1"
    fi
fi


app_dir=/app
slug_dir=/tmp/slug
build_root=/tmp/build
cache_root=/tmp/cache
buildpack_root=/tmp/buildpacks

mkdir -p $slug_dir
mkdir -p $app_dir
mkdir -p $cache_root
mkdir -p $buildpack_root
mkdir -p $build_root/.profile.d

function output_redirect() {
    if [[ "$slug_file" == "-" ]]; then
        cat - 1>&2
    else
        cat -
    fi
}

# define debug info
function debug_info() {
    DEBUG=${DEBUG:=false}
    if [ "$DEBUG" == "true" ];then
      echo $'debug:======>' $* | output_redirect
    fi
}

function echo_title() {
    echo $'builder:----->' $* | output_redirect
}

function echo_normal() {
    echo $'builder:      ' $* | output_redirect
}

function ensure_indent() {
    while read line; do
        if [[ "$line" == --* ]]; then
            echo $'builder:'$line | sed -e "s/--> /--> /" | output_redirect
        else
            echo $'builder:      ' "$line" | output_redirect
        fi
    done
}

## Copy application code over
if [ -d "/tmp/app" ]; then
    cp -rf /tmp/app/. $app_dir
else
    cat | tar -xmC $app_dir
fi

# Precompile commands are executed to pre-compile the user code
debug_info "start pre-compile..."
/bin/bash /tmp/pre-compile/pre-compile $app_dir

# In heroku, there are two separate directories, and some
# buildpacks expect that.
cp -r $app_dir/. $build_root

## Define some of the variables needed for the buildpack
export APP_DIR="$app_dir"
export HOME="$app_dir"
export REQUEST_ID=$(openssl rand -base64 32)
export STACK=cedar-14
export TYPE=${TYPE:-online}

## Write Procfile

if [ $PROCFILE ];then
	echo $PROCFILE > $build_root/Procfile
fi

## Buildpack detection
case "$LANGUAGE" in
"Java-maven")
selected_buildpack="heroku-buildpack-java"
;;
"Java-jar")
selected_buildpack="goodrain-buildpack-java-jar"
;;
"Java-war")
selected_buildpack="goodrain-buildpack-java-war"
;;
"PHP")
selected_buildpack="heroku-buildpack-php"
;;
"Python")
selected_buildpack="heroku-buildpack-python"
;;
"Node.js")
selected_buildpack="heroku-buildpack-nodejs"
;;
"Go")
selected_buildpack="heroku-buildpack-go"
;;
"Gradle")
selected_buildpack="heroku-buildpack-gradle"
;;
"static")
selected_buildpack="heroku-buildpack-static-backports"
;;
"no"|"")
echo_title "Unable to select a buildpack"
exit 1
;;
esac

selected_buildpack="$buildpack_root/$selected_buildpack"

## Buildpack compile
$selected_buildpack/bin/compile "$build_root" "$cache_root" 2>&1 | ensure_indent
$selected_buildpack/bin/release "$build_root" "$cache_root" > $build_root/.release

## Display process types
echo_title "Discovering process types"
if [[ -f "$build_root/Procfile" ]]; then
    types=$(ruby -e "require 'yaml';puts YAML.load_file('$build_root/Procfile').keys().join(', ')")
    echo_normal "Procfile declares types -> $types"
fi
default_types=""
if [[ -s "$build_root/.release" ]]; then
    default_types=$(ruby -e "require 'yaml';puts (YAML.load_file('$build_root/.release')['default_process_types'] || {}).keys().join(', ')")
    [[ $default_types ]] && echo_normal "Default process types for $LANGUAGE -> $default_types"
fi

# pause
sleep ${PAUSE:-0}

## Produce slug

if [[ -f "$build_root/.slugignore" ]]; then
    tar -z --exclude='.git' -X "$build_root/.slugignore" -C $build_root -cf $slug_file .
else
    tar -z --exclude='.git' -C $build_root -cf $slug_file .
fi

if [[ "$slug_file" != "-" ]]; then
    slug_size=$(du -Sh "$slug_file" | cut -f1)
    echo_title "Compiled slug size is $slug_size"

    if [[ $put_url ]]; then
        curl -0 -s -o /dev/null -X PUT -T $slug_file "$put_url"
    fi
fi
