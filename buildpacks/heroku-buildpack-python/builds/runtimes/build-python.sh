#!/bin/bash
# The current script is used to package a portable Python precompiled installation package.
# Scripts can be run in aARCH64 or x86_64, packaged with the corresponding version of Python
versions=(
    2.7.1
    2.7.2
    2.7.3
    2.7.4
    2.7.5
    2.7.6
    2.7.7
    2.7.8
    2.7.9
    2.7.10
    2.7.11
    2.7.12
    2.7.13
    2.7.14
    2.7.15
    2.7.16
    2.7.17
    2.7.18
    3.4.1
    3.4.2
    3.4.3
    3.4.10
    3.4.9
    3.5.0
    3.5.1
    3.5.2
    3.5.3
    3.5.7
    3.6.0
    3.6.1
    3.6.2
    3.5.3
    3.6.4
    3.6.5
    3.6.6
    3.6.10)

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
        cp /app/python-$version/bin/$(echo python${version} | sed 's/..$//') /app/python-$version/bin/python
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
