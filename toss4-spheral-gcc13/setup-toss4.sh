#!/bin/bash

set -e

echo "=========================================="
echo "TOSS4 Spheral GCC 13 Container Setup"
echo "=========================================="
echo

check_command() {
    if command -v "$1" &> /dev/null; then
        echo "✓ $1 found"
        return 0
    else
        echo "✗ $1 not found"
        return 1
    fi
}

echo "Checking requirements..."
check_command podman || { echo "ERROR: podman not found"; exit 1; }
check_command git || { echo "ERROR: git not found"; exit 1; }
echo

echo "Checking X11 forwarding..."
if [ -z "$DISPLAY" ]; then
    echo "⚠ WARNING: DISPLAY not set"
    echo "  Make sure you connected with: ssh -X toss4-dev"
else
    echo "✓ DISPLAY is set: $DISPLAY"
fi
echo

echo "Creating directory structure..."
mkdir -p ~/.container-data/toss4-spheral-gcc13
touch ~/.container-data/toss4-spheral-gcc13/.zsh_history
echo "✓ Created ~/.container-data/toss4-spheral-gcc13/"

mkdir -p ~/projects/spheral
echo "✓ Created ~/projects/spheral/"
echo

echo "Making scripts executable..."
chmod +x build.sh start.sh attach.sh
echo "✓ Scripts are executable"
echo

echo "Checking SSH keys..."
if [ -f ~/.ssh/id_ed25519.pub ] || [ -f ~/.ssh/id_rsa.pub ]; then
    echo "✓ SSH keys found"
else
    echo "⚠ No SSH keys found. Generate with: ssh-keygen -t ed25519"
fi
echo

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo
echo "Next steps:"
echo
echo "1. Build the container image:"
echo "   ./build.sh"
echo
echo "2. Start the container:"
echo "   ./start.sh"
echo
echo "3. Attach to the container:"
echo "   ./attach.sh"
echo
echo "4. Inside container, launch VSCode:"
echo "   code /workspaces/spheral"
echo
echo "Directories created:"
echo "  Container config: ~/containers/toss4-spheral-gcc13/"
echo "  Project work:     ~/projects/spheral/"
echo "  History:          ~/.container-data/toss4-spheral-gcc13/.zsh_history"
echo
