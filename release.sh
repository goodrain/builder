#!/bin/bash

set -xe

commitid=$(git log -n 1 --pretty --format=%h)
release_ver=v5.0
release_desc=${release_ver}-${commitid}
sed "s/__RELEASE_DESC__/$release_desc/" Dockerfile >Dockerfile.release
docker build -t rainbond/builder:${release_ver} -f Dockerfile.release .