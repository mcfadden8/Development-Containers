#!/bin/bash

CONTAINER_NAME="spheral-dev"

if ! podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' is not running."
    exit 0
fi

echo "Stopping container: ${CONTAINER_NAME}"
podman stop ${CONTAINER_NAME}

echo "Container stopped."
echo
echo "Start again with:"
echo "  ./start.sh"
echo
echo "Remove completely with:"
echo "  podman rm ${CONTAINER_NAME}"
echo
