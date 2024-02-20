#!/bin/bash
# The current script is used to package a portable Python precompiled installation package.
# Scripts can be run in aARCH64 or x86_64, packaged with the corresponding version of Python
versions=$1

if [[ $(uname -p) == "aarch64" ]]; then
    ARCH="arm64"
elif [[ "$(uname -p)" = "i686" ]] || [[ "$(uname -p)" = "x86_64" ]] || [[ "$(uname -p)" = "amd64" ]]; then
    ARCH="x86_64"
fi

# Download Python src code
function get_python_code() {
    local version=$1
    [[ ! -d /root/src ]] && mkdir /root/src
    echo ""
    echo ""
    echo "Downloading Python-$version src code in $(pwd)"
    echo ""
    echo ""
    if ! wget --no-check-certificate https://python.org/ftp/python/$version/Python-$version.tgz; then
        echo "$version src can not be download" >>uninstalled
        return 100
    fi
    tar xzf Python-$version.tgz -C /root/src
    rm -rf Python-$version.tgz
}
# Compile python
function compoile_python() {
    local version=$1
    pushd /root/src/Python-$version
    echo ""
    echo ""
    echo "compileing Python-$version in $(pwd)"
    echo ""
    echo ""
    if ! (./configure --prefix=/app/python-$version && make && make install); then
        echo "$version can not be compiled in $ARCH " >>uninstalled
        rm -rf /root/src/Python-$version
        popd
        return 99
    fi
    popd
    rm -rf /root/src/Python-$version
}
# Packaging python tar
function tar_python() {
    local version=$1
    # Remove unneeded test directories, similar to the official Docker Python images:
    # https://github.com/docker-library/python
    find /app/python-$version -depth \
        \( \
        \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
        -o \
        \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +
    if [ ! -f /app/python-$version/bin/python ]; then
        cp /app/python-$version/bin/$(echo python${version} | sed 's/\(.*\)\..*/\1/') /app/python-$version/bin/python
    fi
    if [ ! -f /app/python-$version/bin/pip ] && [ -f /app/python-$version/bin/pip3 ]; then
        mv /app/python-$version/bin/pip3 /app/python-$version/bin/pip
    fi
    pushd /app/python-$version
    tar czf python-$version-$ARCH.tar.gz ./*
    mv python-$version-$ARCH.tar.gz /app
    popd
}
for version in ${versions[@]}; do
    apt-get install libssl-dev
    apt-get install libffi-dev
    get_python_code $version
    if [ $? -eq 100 ]; then
        continue
    fi
    compoile_python $version
    if [ $? -eq 99 ]; then
        continue
    fi
    tar_python $version
done
