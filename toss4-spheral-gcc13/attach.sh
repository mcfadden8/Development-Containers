#!/bin/bash

CONTAINER_NAME="spheral-dev"

if ! podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' is not running."
    echo
    echo "Start it with:"
    echo "  ./start.sh"
    exit 1
fi

echo "Attaching to container: ${CONTAINER_NAME}"
echo "Starting zsh..."
echo

podman exec -it ${CONTAINER_NAME} zsh
