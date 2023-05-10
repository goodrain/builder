#!/bin/bash

# set -xe

commitid=$(git log -n 1 --pretty --format=%h)
# get current branch
# the tag of image, will be selected from :
# 1. custom $RELEASE_VERSION
# 2. $brach_name
# 3. current version like "v5.5.0-release"
brach_name=$(git symbolic-ref --short -q HEAD)
if [ $brach_name == "master" ]; then
    release_version=${RELEASE_VERSION:-"v5.7.0-release"}
else
    release_version=${RELEASE_VERSION:-${brach_name}}
fi

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
    docker tag goodrain.me/builder rainbond/builder:${release_version}
    if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
        docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
        docker push rainbond/builder:${release_version}
    else
        # TODO
        echo ''
    fi
    if [ "${DOMESTIC_BASE_NAME}" ]; then
        new_tag="${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/builder:${release_version}"
        # for amd64 and arm64
        if [ $(arch) == "x86_64" ]; then
            new_tag=${new_tag}
        elif [ $(arch) == "arm64" ] || [ $(arch) == "aarch64" ]; then
            new_tag=${new_tag}-arm64
        fi
        docker tag goodrain.me/builder "$new_tag"
        docker login -u "$DOMESTIC_DOCKER_USERNAME" -p "$DOMESTIC_DOCKER_PASSWORD" "${DOMESTIC_BASE_NAME}"
        docker push "$new_tag"
    fi
}

# create manifest for amd64 and arm64 with same name, push them to aliyun registry.
# this function should run after image pushed.
# manifest will be named like     example/builder:v5.5.0-release
# amd64 images will be named like example/builder:v5.5.0-release
# arm64 images will be named like example/builder:v5.5.0-release-arm64
# manifest list can not be recreated except the image example/builder:v5.5.0-release has been re-pushed.
build::manifest() {
    new_tag="${DOMESTIC_BASE_NAME}/${DOMESTIC_NAMESPACE}/builder:${release_version}"
    docker login -u "$DOMESTIC_DOCKER_USERNAME" -p "$DOMESTIC_DOCKER_PASSWORD" "${DOMESTIC_BASE_NAME}"
    docker manifest create $new_tag $new_tag $new_tag-arm64
    docker manifest annotate $new_tag $new_tag --os linux --arch amd64
    docker manifest annotate $new_tag $new_tag-arm64 --os linux --arch arm64 --variant v8
    docker manifest push $new_tag
    docker manifest rm $new_tag
}

case $1 in
local)
    build::local "${@:2}"
    ;;
manifest)
    build::manifest
    ;;
*)
    build::local
    build::public
    ;;
esac
