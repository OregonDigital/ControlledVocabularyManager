#!/bin/bash

build_no="$1"

if [ -z "$build_no" ]; then
   echo "Usage: $0 <build number>"
   exit 1
fi
tag1="registry.library.oregonstate.edu/cvm_rails:test-${build_no}"

echo "Building for tag $tag1"
docker build . -t "$tag1"

echo "Logging into BCR as admin"
echo admin | docker login --password-stdin registry.library.oregonstate.edu

docker push "$tag1"
