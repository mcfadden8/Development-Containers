#!/bin/bash

set -e

CONTAINER_NAME="spheral-dev"
IMAGE_NAME="toss4-spheral-gcc13:latest"
TAR_FILE="toss4-spheral-gcc13.tar"

if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' already exists."
    if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is running. Use ./attach.sh to connect."
        NODE=$(hostname)
        echo "Access code-server at: http://${NODE}:8080"
        echo "Password: spheral"
        exit 0
    else
        echo "Starting existing container..."
        podman start ${CONTAINER_NAME}
        echo "Container started. Use ./attach.sh to connect."
        NODE=$(hostname)
        echo "Access code-server at: http://${NODE}:8080"
        echo "Password: spheral"
        exit 0
    fi
fi

if ! podman images --format "{{.Repository}}:{{.Tag}}" | grep -q "^localhost/${IMAGE_NAME}$"; then
    echo "Image not found: ${IMAGE_NAME}"
    if [ -f "${TAR_FILE}" ]; then
        echo "Loading image from tar file: ${TAR_FILE}"
        podman load -i ${TAR_FILE}
        echo "Image loaded successfully"
    else
        echo "ERROR: Image not found and tar file not found: ${TAR_FILE}"
        echo "Run ./build.sh first"
        exit 1
    fi
fi

echo "=========================================="
echo "Starting TOSS4 Spheral Development Container"
echo "=========================================="
echo

NODE=$(hostname)
echo "Hostname: $NODE"
echo "Container: $CONTAINER_NAME"
echo "Image: $IMAGE_NAME"
echo

SSH_AGENT_MOUNT=""
SSH_AGENT_ENV=""
if [ -n "$SSH_AUTH_SOCK" ]; then
    SSH_AGENT_MOUNT="--volume ${SSH_AUTH_SOCK}:/ssh-agent:rw"
    SSH_AGENT_ENV="--env SSH_AUTH_SOCK=/ssh-agent"
    echo "SSH agent forwarding: enabled"
else
    echo "SSH agent forwarding: disabled (SSH_AUTH_SOCK not set)"
fi
echo

podman run -d \
    --name ${CONTAINER_NAME} \
    --hostname toss4-dev-container \
    --network host \
    --userns=keep-id:uid=1000,gid=1000 \
    --volume ${HOME}/projects/spheral:/workspaces/spheral:rw \
    --volume ${HOME}/.ssh:/home/developer/.ssh:ro \
    --volume ${HOME}/.container-data/toss4-spheral-gcc13/.zsh_history:/home/developer/.zsh_history:rw \
    ${SSH_AGENT_MOUNT} \
    ${SSH_AGENT_ENV} \
    ${IMAGE_NAME} \
    sleep infinity

echo
echo "=========================================="
echo "Container Started!"
echo "=========================================="
echo
echo "Container name: ${CONTAINER_NAME}"
echo
echo "Access code-server (VSCode in browser):"
echo "  http://${NODE}:8080"
echo "  Password: spheral"
echo
echo "Attach to shell:"
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
#!/bin/bash

set -e

CONTAINER_NAME="spheral-dev"
IMAGE_NAME="toss4-spheral-gcc13:latest"
TAR_FILE="toss4-spheral-gcc13.tar"

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

if ! podman images --format "{{.Repository}}:{{.Tag}}" | grep -q "^localhost/${IMAGE_NAME}$"; then
    echo "Image not found: ${IMAGE_NAME}"
    if [ -f "${TAR_FILE}" ]; then
        echo "Loading image from tar file: ${TAR_FILE}"
        podman load -i ${TAR_FILE}
        echo "Image loaded successfully"
    else
        echo "ERROR: Image not found and tar file not found: ${TAR_FILE}"
        echo "Run ./build.sh first"
        exit 1
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

SSH_AGENT_MOUNT=""
SSH_AGENT_ENV=""
if [ -n "$SSH_AUTH_SOCK" ]; then
    SSH_AGENT_MOUNT="--volume ${SSH_AUTH_SOCK}:/ssh-agent:rw"
    SSH_AGENT_ENV="--env SSH_AUTH_SOCK=/ssh-agent"
    echo "SSH agent forwarding: enabled"
else
    echo "SSH agent forwarding: disabled (SSH_AUTH_SOCK not set)"
fi
echo

podman run -d \
    --name ${CONTAINER_NAME} \
    --hostname toss4-dev-container \
    --network host \
    --userns=keep-id:uid=1000,gid=1000 \
    --env DISPLAY=${DISPLAY} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --volume ${HOME}/.Xauthority:/home/developer/.Xauthority:ro \
    --volume ${HOME}/projects/spheral:/workspaces/spheral:rw \
    --volume ${HOME}/.ssh:/home/developer/.ssh:ro \
    --volume ${HOME}/.container-data/toss4-spheral-gcc13/.zsh_history:/home/developer/.zsh_history:rw \
    ${SSH_AGENT_MOUNT} \
    ${SSH_AGENT_ENV} \
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

SSH_AGENT_MOUNT=""
SSH_AGENT_ENV=""
if [ -n "$SSH_AUTH_SOCK" ]; then
    SSH_AGENT_MOUNT="--volume ${SSH_AUTH_SOCK}:/ssh-agent:rw"
    SSH_AGENT_ENV="--env SSH_AUTH_SOCK=/ssh-agent"
    echo "SSH agent forwarding: enabled"
else
    echo "SSH agent forwarding: disabled (SSH_AUTH_SOCK not set)"
fi
echo

podman run -d \
    --name ${CONTAINER_NAME} \
    --hostname toss4-dev-container \
    --network host \
    --userns=keep-id:uid=1000,gid=1000 \
    --env DISPLAY=${DISPLAY} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --volume ${HOME}/.Xauthority:/home/developer/.Xauthority:ro \
    --volume ${HOME}/projects/spheral:/workspaces/spheral:rw \
    --volume ${HOME}/.ssh:/home/developer/.ssh:ro \
    --volume ${HOME}/.container-data/toss4-spheral-gcc13/.zsh_history:/home/developer/.zsh_history:rw \
    ${SSH_AGENT_MOUNT} \
    ${SSH_AGENT_ENV} \
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
    --userns=keep-id:uid=1000,gid=1000 \
    --env DISPLAY=${DISPLAY} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --volume ${HOME}/.Xauthority:/home/developer/.Xauthority:ro \
    --volume ${HOME}/projects/spheral:/workspaces/spheral:rw \
    --volume ${HOME}/.ssh:/home/developer/.ssh:ro \
    --volume ${HOME}/.container-data/toss4-spheral-gcc13/.zsh_history:/home/developer/.zsh_history:rw \
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
