#!/bin/bash

set -e

IMAGE_NAME="toss4-spheral-gcc13"
IMAGE_TAG="latest"

echo "=========================================="
echo "Building TOSS4 Spheral GCC 13 Container"
echo "=========================================="
echo

cd "$(dirname "$0")"

echo "Building image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo

podman build \
    --userns-uid-map=0:0:1 --userns-uid-map=1:1:1999 --userns-uid-map=65534:2000:2 \
    --tag ${IMAGE_NAME}:${IMAGE_TAG} \
    --file Dockerfile \
    .

echo
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo
echo "Next steps:"
echo "  ./start.sh   - Start the container"
echo "  ./attach.sh  - Attach to running container"
echo
