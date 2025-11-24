# TOSS4 Spheral GCC 13 Development Container

Full-featured development container for LLNL TOSS4 systems with all development tools self-contained.

## Purpose

This is a fat container designed to run on TOSS4 systems where you want a complete, reproducible development environment without relying on host-installed tools. Unlike the thin container approach, this includes:

- GCC 13 compiler toolchain
- OpenMPI for MPI development
- Python 3 with development libraries
- Git, vim, tree, and development utilities
- Zsh with oh-my-zsh configuration
- All build tools and libraries

## What's Included

**Compilers:**
- GCC 13.x (default)
- G++ 13.x
- OpenMPI 4.x

**Development Tools:**
- CMake, Ninja
- GDB, Valgrind
- Git, Vim, Tree
- Python 3.10+

**Shell:**
- Zsh with oh-my-zsh
- zsh-autosuggestions
- zsh-syntax-highlighting
- Shared history across sessions

## User Configuration

- **Username:** martymcf
- **UID:** 54987 (matches TOSS4 host UID)
- **GID:** 54987
- **Shell:** /usr/bin/zsh
- **Home:** /home/martymcf

## Directory Structure

**On TOSS4 Host:**
```
~/containers/toss4-spheral-gcc13/    # This container config
~/projects/spheral/                  # Your Spheral source (mounted)
~/.container-data/
  └── toss4-spheral-gcc13/
      └── .zsh_history              # Persistent shell history
~/.ssh/                             # SSH keys (mounted readonly)
```

**Inside Container:**
```
/home/martymcf/                     # Container home directory
/workspaces/spheral/                # Mounted from ~/projects/spheral
/home/martymcf/.zsh_history         # Mounted from persistent storage
/home/martymcf/.ssh/                # Mounted from host (readonly)
```

## Setup on TOSS4

### First Time Setup

```bash
# On TOSS4
cd ~
git clone git@github.com:mcfadden8/Development-Containers.git containers

# Create persistent directories
mkdir -p ~/.container-data/toss4-spheral-gcc13
touch ~/.container-data/toss4-spheral-gcc13/.zsh_history
mkdir -p ~/projects/spheral

# Configure Podman
systemctl --user enable --now podman.socket
```

### Configure VSCode for Podman

```bash
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json << 'EOF'
{
  "dev.containers.dockerPath": "podman"
}
EOF
```

## Usage with VSCode Remote-SSH

### From WSL2

```bash
# In VSCode (connected to WSL2)
# F1 → Remote-SSH: Connect to Host → toss4-dev

# Once connected to TOSS4:
# File → Open Folder → ~/containers/toss4-spheral-gcc13
# F1 → Dev Containers: Reopen in Container
```

## Compiler Configuration

GCC 13 is set as the default compiler:

```bash
gcc --version    # gcc 13.x
g++ --version    # g++ 13.x
mpicxx --version # OpenMPI with g++ 13
```

## SSH Agent Forwarding

SSH agent is forwarded from the host, allowing you to:
- Clone/push to GitHub from inside container
- SSH to other systems using your host keys
- No need to copy private keys into container

## Image Size

Base image: ~2.5GB (includes all development tools and libraries)

This is self-contained and portable - the same image works on any TOSS4 node.

## Differences from WSL2 Containers

- User is `martymcf` (UID 54987) instead of `developer` (UID 1000)
- Designed for TOSS4 environment
- Same tools and configuration as spheral-gcc13 on WSL2
- Workspace mounted from `~/projects/spheral` instead of `~/dev/containers/...`
