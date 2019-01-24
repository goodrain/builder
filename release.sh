#!/bin/bash

set -xe

commitid=$(git log -n 1 --pretty --format=%h)
release_ver=master
release_desc=${release_ver}-${commitid}
sed "s/__RELEASE_DESC__/$release_desc/" Dockerfile >Dockerfile.release
docker build --no-cache -t rainbond/rbd-builder:${release_ver} -f Dockerfile.release .
rm -rf Dockerfile.release
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then 
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD && \
  docker push rainbond/rbd-builder:${release_ver};
fi
