#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "======================================"
echo "WSL2 + Podman + VSCode Verification"
echo "======================================"
echo ""

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "1. Checking WSL2 Configuration..."
if grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
    check_pass "systemd enabled in /etc/wsl.conf"
else
    check_fail "systemd not enabled in /etc/wsl.conf"
    echo "   Expected: [boot] systemd=true"
fi

if systemctl status >/dev/null 2>&1; then
    check_pass "systemd is running"
else
    check_fail "systemd is not running"
fi

echo ""
echo "2. Checking Podman Installation..."
if command -v podman >/dev/null 2>&1; then
    check_pass "Podman installed: $(podman --version)"
else
    check_fail "Podman not installed"
fi

if systemctl --user is-active podman.socket >/dev/null 2>&1; then
    check_pass "Podman socket is active"
else
    check_fail "Podman socket is not active"
    echo "   Run: systemctl --user start podman.socket"
fi

if systemctl --user is-enabled podman.socket >/dev/null 2>&1; then
    check_pass "Podman socket is enabled"
else
    check_warn "Podman socket not enabled (won't auto-start)"
    echo "   Run: systemctl --user enable podman.socket"
fi

echo ""
echo "3. Checking Project Structure..."
if [ -d ~/dev/ubuntu-dev ]; then
    check_pass "Project directory exists: ~/dev/ubuntu-dev"
else
    check_fail "Project directory missing: ~/dev/ubuntu-dev"
fi

if [ -f ~/dev/ubuntu-dev/Dockerfile ]; then
    check_pass "Dockerfile exists"
else
    check_fail "Dockerfile missing"
fi

if [ -d ~/dev/ubuntu-dev/.devcontainer ]; then
    check_pass ".devcontainer directory exists"
else
    check_fail ".devcontainer directory missing"
fi

if [ -f ~/dev/ubuntu-dev/.devcontainer/devcontainer.json ]; then
    check_pass "devcontainer.json exists"
else
    check_fail "devcontainer.json missing"
fi

echo ""
echo "4. Checking SSH Setup..."
if [ -d ~/.ssh ]; then
    check_pass "~/.ssh directory exists"
    if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
        check_pass "SSH keys present"
    else
        check_warn "No SSH keys found (id_rsa or id_ed25519)"
    fi
else
    check_fail "~/.ssh directory missing"
fi

echo ""
echo "5. Checking History Persistence..."
if [ -d ~/.container-data/ubuntu-dev ]; then
    check_pass "Container data directory exists"
else
    check_warn "Container data directory missing (will be created)"
    echo "   mkdir -p ~/.container-data/ubuntu-dev"
fi

if [ -f ~/.container-data/ubuntu-dev/.zsh_history ]; then
    check_pass "Zsh history file exists"
else
    check_warn "Zsh history file missing (will be created on first use)"
fi

echo ""
echo "6. Checking VSCode Configuration..."
if [ -f ~/.config/Code/User/settings.json ]; then
    check_pass "VSCode settings.json exists"
    if grep -q "podman" ~/.config/Code/User/settings.json; then
        check_pass "VSCode configured for Podman"
    else
        check_warn "VSCode settings.json doesn't mention Podman"
    fi
else
    check_fail "VSCode settings.json not found"
    echo "   Expected: ~/.config/Code/User/settings.json"
fi

echo ""
echo "7. Checking Container Image..."
if podman images | grep -q ubuntu-dev; then
    IMAGE_INFO=$(podman images --format "{{.Repository}}:{{.Tag}} - Created: {{.CreatedAt}}" | grep ubuntu-dev | head -1)
    check_pass "ubuntu-dev image exists"
    echo "   $IMAGE_INFO"
else
    check_warn "ubuntu-dev image not built yet"
    echo "   cd ~/dev/ubuntu-dev && podman build -t ubuntu-dev:latest ."
fi

echo ""
echo "8. Checking Running Container..."
if podman ps --format "{{.Image}}" | grep -q "vsc-ubuntu-dev"; then
    CONTAINER=$(podman ps --format "{{.Names}}" | head -1)
    check_pass "Container is running: $CONTAINER"

    echo ""
    echo "9. Checking Container Configuration..."
    if podman exec "$CONTAINER" test -d /workspaces/ubuntu-dev 2>/dev/null; then
        check_pass "Workspace mounted in container"
    else
        check_warn "Workspace not accessible in container"
    fi

    if podman exec "$CONTAINER" test -d /home/developer/.ssh 2>/dev/null; then
        check_pass "SSH directory mounted in container"
    else
        check_warn "SSH directory not accessible in container"
    fi

    if podman exec "$CONTAINER" test -f /home/developer/.zsh_history 2>/dev/null; then
        check_pass "Zsh history mounted in container"
    else
        check_warn "Zsh history not accessible in container"
    fi

    if podman exec "$CONTAINER" which gcc >/dev/null 2>&1; then
        GCC_VER=$(podman exec "$CONTAINER" gcc --version | head -1)
        check_pass "GCC available: $GCC_VER"
    fi

    if podman exec "$CONTAINER" which python3 >/dev/null 2>&1; then
        PYTHON_VER=$(podman exec "$CONTAINER" python3 --version)
        check_pass "Python available: $PYTHON_VER"
    fi

    if podman exec "$CONTAINER" which mpic++ >/dev/null 2>&1; then
        check_pass "MPICH available"
    fi

    if podman exec "$CONTAINER" which zsh >/dev/null 2>&1; then
        check_pass "Zsh available"
    fi
else
    check_warn "No container currently running"
    echo "   Start container: cd ~/dev/ubuntu-dev && code ."
    echo "   Then: F1 → 'Dev Containers: Reopen in Container'"
fi

echo ""
echo "======================================"
echo "Verification Complete"
echo "======================================"
