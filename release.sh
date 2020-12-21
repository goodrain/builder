#!/bin/bash

set -xe

commitid=$(git log -n 1 --pretty --format=%h)
release_ver=v5.3.0

DOMESTIC_BASE_NAME=${DOMESTIC_BASE_NAME:-'registry.cn-hangzhou.aliyuncs.com'}
DOMESTIC_NAMESPACE=${DOMESTIC_NAMESPACE:-'goodrain'}

build::local() {
    release_desc=${release_ver}-${commitid}
    sed "s/__RELEASE_DESC__/$release_desc/" Dockerfile >Dockerfile.release
    docker build --no-cache -t goodrain.me/builder -f Dockerfile.release .
    rm -rf Dockerfile.release
    if [ "$1" == "push" ]; then
        docker push goodrain.me/builder
    else
        # TODO
        echo ''
    fi
}

build::public() {
    docker tag goodrain.me/builder rainbond/builder:${release_ver}
    if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
        docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
        docker push rainbond/builder:${release_ver}
        if [ "${DOMESTIC_BASE_NAME}" ]; then
            new_tag="${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/builder:${release_ver}"
            docker tag goodrain.me/builder "$new_tag"
            docker login -u "$DOMESTIC_DOCKER_USERNAME" -p "$DOMESTIC_DOCKER_PASSWORD" "${DOMESTIC_BASE_NAME}"
            docker push "$new_tag"
        fi
    else
        # TODO
        echo ''
    fi
}

case $1 in
local)
    build::local "${@:2}"
    ;;
*)
    build::local
    build::public
    ;;
esac
