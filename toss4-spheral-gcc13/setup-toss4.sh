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

echo "Creating directory structure..."
mkdir -p ~/.container-data/toss4-spheral-gcc13
touch ~/.container-data/toss4-spheral-gcc13/.zsh_history
echo "✓ Created ~/.container-data/toss4-spheral-gcc13/"

mkdir -p ~/projects/spheral
echo "✓ Created ~/projects/spheral/"
echo

echo "Configuring Podman socket..."
systemctl --user enable --now podman.socket 2>/dev/null || true
if systemctl --user is-active --quiet podman.socket; then
    echo "✓ Podman socket is active"
else
    echo "⚠ Podman socket not active, may need manual start"
fi
echo

echo "Configuring VSCode for Podman..."
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json << 'EOF'
{
  "dev.containers.dockerPath": "podman"
}
EOF
echo "✓ Created ~/.config/Code/User/settings.json"
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
echo "1. From WSL2 VSCode:"
echo "   F1 → Remote-SSH: Connect to Host → toss4-dev"
echo
echo "2. Once connected to TOSS4:"
echo "   File → Open Folder → ~/containers/toss4-spheral-gcc13"
echo
echo "3. Open in container:"
echo "   F1 → Dev Containers: Reopen in Container"
echo
echo "Directories created:"
echo "  Container config: ~/containers/toss4-spheral-gcc13/"
echo "  Project work:     ~/projects/spheral/"
echo "  History:          ~/.container-data/toss4-spheral-gcc13/.zsh_history"
echo
