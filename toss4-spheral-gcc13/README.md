# TOSS4 Spheral GCC 13 Development Container

Full-featured development container for LLNL TOSS4 systems with VSCode and all development tools running inside the container.

## Purpose

This is a fat container designed to run on TOSS4 systems as a complete, self-contained development environment. Everything runs inside the container:

- GCC 13 compiler toolchain
- OpenMPI for MPI development
- Python 3 with development libraries
- VSCode with extensions pre-installed
- Git, vim, tree, and development utilities
- Zsh with oh-my-zsh configuration
- All build tools and libraries

## Architecture

You SSH to TOSS4 with X11 forwarding, build the container, start it, attach to it, and run VSCode inside. The TOSS4 host only runs Podman - everything else is in the container.

```
Local Machine
    ↓ ssh -X
TOSS4 Host (Podman only)
    ↓ manages
Container (VSCode, GCC, tools)
```

## What's Included

**Compilers:**
- GCC 13.x (default)
- G++ 13.x
- OpenMPI 4.x

**Development Tools:**
- VSCode with extensions:
  - C/C++ Extension Pack
  - CMake Tools
  - Python
  - Pylance
  - Makefile Tools
  - GitLens
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

### Prerequisites

**From your local machine, SSH with X11 forwarding:**

```bash
ssh -X toss4-dev
```

Verify X11 forwarding works:

```bash
echo $DISPLAY
xeyes  # Should open a GUI window
```

### First Time Setup

```bash
cd ~
git clone git@github.com:mcfadden8/Development-Containers.git containers

mkdir -p ~/.container-data/toss4-spheral-gcc13
touch ~/.container-data/toss4-spheral-gcc13/.zsh_history
mkdir -p ~/projects/spheral

cd ~/containers/toss4-spheral-gcc13
chmod +x *.sh
```

## Usage

### Build the Container

```bash
cd ~/containers/toss4-spheral-gcc13
./build.sh
```

First build takes ~10-15 minutes (downloads and installs everything).

### Start the Container

```bash
./start.sh
```

This starts the container in the background with all mounts configured.

### Attach to the Container

```bash
./attach.sh
```

You're now inside the container with zsh.

### Launch VSCode

**Inside the container:**

```bash
cd /workspaces/spheral
code .
```

VSCode GUI opens on your local machine via X11 forwarding.

### Daily Workflow

```bash
# SSH to TOSS4 with X11
ssh -X toss4-dev

# Start container (if not running)
cd ~/containers/toss4-spheral-gcc13
./start.sh

# Attach to container
./attach.sh

# Inside container: launch VSCode
code /workspaces/spheral

# Work in VSCode...

# When done, exit container shell (container keeps running)
exit

# Later: reattach anytime
./attach.sh
```

### Stop the Container

```bash
podman stop spheral-dev
```

### Remove the Container

```bash
podman rm spheral-dev
```

Then `./start.sh` to create fresh.

## Compiler Configuration

GCC 13 is set as the default compiler:

```bash
gcc --version    # gcc 13.x
g++ --version    # g++ 13.x
mpicxx --version # OpenMPI with g++ 13
```

VSCode is configured to use GCC 13 for IntelliSense.

## SSH Agent Forwarding

SSH agent is forwarded from the host, allowing you to:
- Clone/push to GitHub from inside container
- SSH to other systems using your host keys
- No need to copy private keys into container

## Persistent Data

**What persists across container restarts:**
- `/workspaces/spheral` - Your project files
- Shell history
- VSCode settings and extensions (stored in container)

**What's ephemeral:**
- Anything in `/home/martymcf` not mounted from host
- Installed packages (unless you rebuild image)

## Troubleshooting

**VSCode won't launch:**

```bash
# Check DISPLAY
echo $DISPLAY

# Check X11 forwarding
xeyes
```

If DISPLAY is empty, reconnect with `ssh -X toss4-dev`

**Container won't start:**

```bash
# Check if container exists
podman ps -a

# Remove old container
podman rm spheral-dev

# Start fresh
./start.sh
```

**X11 authentication errors:**

```bash
# On TOSS4, regenerate .Xauthority
rm ~/.Xauthority
logout
# SSH back in with -X
```

## Image Size

Base image: ~3.5GB (includes VSCode, all compilers, libraries, and tools)

This is completely self-contained and portable across any TOSS4 node.

## Scripts Reference

- **build.sh** - Build the container image
- **start.sh** - Start the container (creates if doesn't exist)
- **attach.sh** - Attach to running container with zsh
- **setup-toss4.sh** - One-time setup of directories

## Notes

- Container uses `--network host` for simplicity
- X11 socket and .Xauthority are mounted for GUI support
- All source code lives on host filesystem (survives container deletion)
- VSCode extensions and settings are inside container (need rebuild to persist)
