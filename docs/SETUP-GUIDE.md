# WSL2 + Podman + VSCode Development Container Setup

Complete setup guide for containerized development environments on Windows 11.

**Repository:** https://github.com/mcfadden8/Development-Containers

## Overview

This guide helps you set up a reproducible development environment using:
- **WSL2** (Windows Subsystem for Linux 2) on Windows 11
- **Podman** for container management (Docker alternative)
- **VSCode** with Dev Containers extension
- **Ubuntu 22.04** base containers with custom toolchains

## Prerequisites

- Windows 11 with administrator access
- At least 16GB RAM
- 50GB free disk space
- Basic familiarity with Linux command line

## Quick Start

If you already have WSL2, Podman, and VSCode configured:

```bash
cd ~/dev
git clone https://github.com/mcfadden8/Development-Containers.git containers
cd containers/spheral-gcc11
code .
```

Then in VSCode: `F1` → `Dev Containers: Reopen in Container`

## Full Installation

### Step 1: Install WSL2 with Ubuntu

Open PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu-24.04
```

**Restart your computer** when prompted.

After restart, Ubuntu opens automatically. Create your user account:
- Username: (your preferred username)
- Password: (needed for sudo)

Verify installation:
```powershell
wsl --list --verbose
```

Should show Ubuntu-24.04 with version 2.

### Step 2: Configure WSL2 Resources

Create `C:\Users\<YourUsername>\.wslconfig` with Notepad (as Administrator):

```ini
[wsl2]
memory=16GB
processors=8
swap=8GB
localhostForwarding=true
```

Restart WSL:
```powershell
wsl --shutdown
wsl
```

### Step 3: Enable Systemd in WSL2

**Critical step** - Podman requires systemd.

In WSL2 terminal:

```bash
sudo vim /etc/wsl.conf
```

Add:
```ini
[boot]
systemd=true
```

Save and exit WSL:
```bash
exit
```

In PowerShell, restart WSL:
```powershell
wsl --shutdown
wsl
```

Verify systemd is running:
```bash
systemctl --version
```

### Step 4: Update Ubuntu and Install Base Tools

```bash
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y \
  build-essential \
  git \
  curl \
  wget \
  vim \
  zsh \
  ca-certificates \
  gnupg \
  lsb-release
```

### Step 5: Install Podman

```bash
sudo apt-get install -y podman podman-compose
podman --version

systemctl --user enable --now podman.socket
systemctl --user status podman.socket
```

Should show "active (listening)".

### Step 6: Configure SSH Agent in WSL2

Set up SSH agent auto-start:

```bash
vim ~/.zshrc
```

Add at the end:

```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi
```

Source the configuration:
```bash
source ~/.zshrc
```

Verify:
```bash
echo $SSH_AUTH_SOCK
ssh-add -l
```

### Step 7: Install VSCode on Windows

1. Download from https://code.visualstudio.com/
2. Run installer
3. Launch VSCode

### Step 8: Install VSCode Extensions

Press `Ctrl+Shift+X` and install:
- **Remote - WSL** (ms-vscode-remote.remote-wsl)
- **Dev Containers** (ms-vscode-remote.remote-containers)

Restart VSCode.

### Step 9: Configure VSCode for Podman

Create VSCode settings file in WSL2:

```bash
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json << 'EOF'
{
    "dev.containers.dockerPath": "podman",
    "dev.containers.dockerComposePath": "podman-compose",
    "terminal.integrated.defaultProfile.linux": "zsh"
}
EOF
```

### Step 10: Clone Repository

```bash
cd ~/dev
git clone https://github.com/mcfadden8/Development-Containers.git containers
cd containers
```

### Step 11: Set Up Container Data Directory

Create directory for persistent container data:

```bash
mkdir -p ~/.container-data/spheral-gcc11
touch ~/.container-data/spheral-gcc11/.zsh_history
```

### Step 12: Open Container in VSCode

```bash
cd ~/dev/containers/spheral-gcc11
code .
```

In VSCode:
1. Press `F1`
2. Type: `Dev Containers: Reopen in Container`
3. Wait for build (first time takes 5-10 minutes)

### Step 13: Verify Setup

Once inside the container, open the terminal and run:

```bash
./verify-setup.sh
```

Or manually check:
```bash
pwd                    # Should be /workspaces/spheral-gcc11
gcc --version          # Should show GCC 11
mpic++ --version       # Should show MPICH
python3 --version      # Should show Python 3.10
zsh --version          # Should show Zsh
ls -la ~/.ssh          # SSH keys should be mounted
```

## Container Structure

Each container directory contains:
- `<name>.Dockerfile` - Container image definition
- `.devcontainer/devcontainer.json` - VSCode container configuration
- `verify-setup.sh` - Verification script

## Available Containers

### spheral-gcc11

Ubuntu 22.04 development environment with:
- GCC 11.4.0, G++, GFortran
- MPICH 4.1.1 for MPI development
- Python 3.10.12
- Zsh with Oh-My-Zsh
- Development tools (cmake, gdb, valgrind, etc.)

**Use case:** Spheral physics simulation framework development

## Creating New Containers

To create a variant (e.g., `spheral-gcc13`):

```bash
cd ~/dev/containers
cp -r spheral-gcc11 spheral-gcc13
cd spheral-gcc13

# Update all references from gcc11 to gcc13
sed -i 's/gcc11/gcc13/g' *.Dockerfile .devcontainer/devcontainer.json verify-setup.sh

# Create history directory
mkdir -p ~/.container-data/spheral-gcc13
touch ~/.container-data/spheral-gcc13/.zsh_history

# Commit to git
git add spheral-gcc13
git commit -m "Add Spheral GCC 13 container"
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

## Additional Resources

- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Daily command reference
- [SSH-SETUP.md](SSH-SETUP.md) - SSH configuration details
- Repository: https://github.com/mcfadden8/Development-Containers
