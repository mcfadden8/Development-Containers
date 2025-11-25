#!/bin/bash

CONTAINER_NAME="spheral-dev"

if ! podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' is not running."
    echo "Start it with: ./start.sh"
    exit 1
fi

echo "Starting code-server in container..."
echo

podman exec -d ${CONTAINER_NAME} code-server /workspaces/spheral

sleep 2

NODE=$(hostname)
echo "=========================================="
echo "code-server Started!"
echo "=========================================="
echo
echo "Access VSCode in your browser:"
echo "  http://${NODE}:8080"
echo
echo "Password: spheral"
echo
echo "To stop code-server:"
echo "  podman exec ${CONTAINER_NAME} pkill code-server"
echo
