#!/bin/bash

set -e

CONTAINER_NAME="spheral-dev"
IMAGE_NAME="toss4-spheral-gcc13:latest"

if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' already exists."
    if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is running. Use ./attach.sh to connect."
        exit 0
    else
        echo "Starting existing container..."
        podman start ${CONTAINER_NAME}
        echo "Container started. Use ./attach.sh to connect."
        exit 0
    fi
fi

echo "=========================================="
echo "Starting TOSS4 Spheral Development Container"
echo "=========================================="
echo

if [ -z "$DISPLAY" ]; then
    echo "WARNING: DISPLAY not set. X11 forwarding may not work."
    echo "Connect with: ssh -X toss4-dev"
    DISPLAY=:0
fi

echo "DISPLAY: $DISPLAY"
echo "Container: $CONTAINER_NAME"
echo "Image: $IMAGE_NAME"
echo

podman run -d \
    --name ${CONTAINER_NAME} \
    --hostname toss4-dev-container \
    --network host \
    --env DISPLAY=${DISPLAY} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --volume ${HOME}/.Xauthority:/home/martymcf/.Xauthority:ro \
    --volume ${HOME}/projects/spheral:/workspaces/spheral:rw \
    --volume ${HOME}/.ssh:/home/martymcf/.ssh:ro \
    --volume ${HOME}/.container-data/toss4-spheral-gcc13/.zsh_history:/home/martymcf/.zsh_history:rw \
    --volume ${SSH_AUTH_SOCK}:/ssh-agent:rw \
    --env SSH_AUTH_SOCK=/ssh-agent \
    ${IMAGE_NAME} \
    sleep infinity

echo
echo "=========================================="
echo "Container Started!"
echo "=========================================="
echo
echo "Container name: ${CONTAINER_NAME}"
echo
echo "Attach with:"
echo "  ./attach.sh"
echo
echo "Or directly:"
echo "  podman exec -it ${CONTAINER_NAME} zsh"
echo
echo "Stop with:"
echo "  podman stop ${CONTAINER_NAME}"
echo
echo "Remove with:"
echo "  podman rm ${CONTAINER_NAME}"
echo
