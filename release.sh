#!/bin/bash
set -xe

build_time=$(date +%F-%H)
git_commit=$(git log -n 1 --pretty --format=%h)
release_desc=${VERSION}-${git_commit}-${build_time}

PUSH_IMAGE=${PUSH_IMAGE:-'true'}
IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-'rainbond'}

docker build --build-arg RELEASE_DESC="${release_desc}" -t "$IMAGE_NAMESPACE"/builder:"$VERSION" .

if [ "$PUSH_IMAGE" == "true" ]; then
    docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
    docker push "$IMAGE_NAMESPACE"/builder:"$VERSION"
fi