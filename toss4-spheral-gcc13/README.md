# TOSS4 Spheral GCC 13 Development Container

Full-featured development container for LLNL TOSS4 systems with browser-based VSCode (code-server).

## Purpose

This is a complete development environment for TOSS4 systems:

- GCC 13 compiler toolchain
- OpenMPI for MPI development
- Python 3 with development libraries
- code-server (VSCode in browser) with extensions pre-installed
- Git, vim, tree, and development utilities
- Zsh with oh-my-zsh configuration
- All build tools and libraries

## Architecture

Access VSCode through your browser - no X11 forwarding needed, much more stable for VNC → SSH → compute node workflows.

```
Your Browser (in VNC or local)
    ↓ http://compute-node:8080
Container running code-server
```

## What's Included

**Compilers:**
- GCC 13.x (default)
- G++ 13.x
- OpenMPI 4.x

**Development Tools:**
- code-server (VSCode in browser) with extensions:
  - C/C++ Extension Pack
  - CMake Tools
  - Python
  - Pylance
  - Makefile Tools
  - GitLens
- CMake, Ninja
- GDB, Valgrind
- Git, Vim, Tree
- Python 3.12+

**Shell:**
- Zsh with oh-my-zsh
- zsh-autosuggestions
- zsh-syntax-highlighting
- Shared history across sessions

## User Configuration

- **Username:** developer
- **UID:** 1000 (in container, remapped to host UID at runtime)
- **GID:** 1000
- **Shell:** /usr/bin/zsh
- **Home:** /home/developer
- **code-server password:** spheral

**At runtime:** Your host UID is automatically remapped to container UID 1000, so files you create appear as owned by you on the host.

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
/home/developer/                    # Container home directory
/workspaces/spheral/                # Mounted from ~/projects/spheral
/home/developer/.zsh_history        # Mounted from persistent storage
/home/developer/.ssh/               # Mounted from host (readonly)
```

## Setup on TOSS4

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

First build takes ~5-10 minutes. Creates tar file automatically.

### Start the Container

```bash
./start.sh
```

Shows the URL to access code-server.

### Access VSCode in Browser

**From your VNC session or local browser:**

```
http://<compute-node-name>:8080
```

For example: `http://rzadams1029:8080`

**Password:** `spheral`

### Start code-server

```bash
./start-code-server.sh
```

Or manually inside container:

```bash
./attach.sh
code-server /workspaces/spheral
```

### Daily Workflow

```bash
# SSH to TOSS4
ssh rzadams.llnl.gov

# Get flux allocation
flux alloc -N 1 -t 8h

# On compute node
cd ~/containers/toss4-spheral-gcc13

# Start container
./start.sh

# Start code-server
./start-code-server.sh

# Open browser to: http://<node>:8080
# Password: spheral

# Work in VSCode...

# When done, stop container
podman stop spheral-dev
```

### Attach to Shell

```bash
./attach.sh
```

Gets you a zsh prompt inside the container for command-line work.

### Stop the Container

```bash
podman stop spheral-dev
```

### Remove the Container

```bash
podman rm spheral-dev
```

## Compiler Configuration

GCC 13 is set as the default compiler:

```bash
gcc --version    # gcc 13.3.0
g++ --version    # g++ 13.3.0
mpicxx --version # OpenMPI with g++ 13
```

VSCode is configured to use GCC 13 for IntelliSense.

## SSH Agent Forwarding

SSH agent is forwarded from the host (if available), allowing you to:
- Clone/push to GitHub from inside container
- SSH to other systems using your host keys
- No need to copy private keys into container

## Persistent Data

**What persists across container restarts:**
- `/workspaces/spheral` - Your project files
- Shell history
- code-server settings and extensions (stored in container)

**What's ephemeral:**
- Anything in `/home/developer` not mounted from host
- Installed packages (unless you rebuild image)

## Changing the Password

Edit the Dockerfile and change the password line:

```dockerfile
echo 'password: YOUR_PASSWORD_HERE' >> ${HOME}/.config/code-server/config.yaml
```

Then rebuild.

## Troubleshooting

**Can't access http://node:8080:**

```bash
# Check container is running
podman ps

# Check code-server is running in container
podman exec spheral-dev ps aux | grep code-server

# Start code-server if not running
./start-code-server.sh
```

**Port 8080 already in use:**

Edit the Dockerfile and change `8080` to another port, then rebuild.

**Browser connection refused:**

Make sure you're using the correct hostname. From the compute node:

```bash
hostname  # Use this exact name in the URL
```

## Image Size

Base image: ~2.3GB (no X11 libraries, lighter than GUI version)

## Scripts Reference

- **build.sh** - Build the container image and save to tar
- **start.sh** - Start the container
- **start-code-server.sh** - Start code-server inside container
- **attach.sh** - Attach to running container with zsh
- **stop.sh** - Stop the container
- **setup-toss4.sh** - One-time setup of directories

## Advantages Over X11/GUI VSCode

- ✅ No X11 forwarding needed
- ✅ Stable across VNC sessions
- ✅ Works through multiple SSH hops
- ✅ Access from any browser
- ✅ Better performance over network
- ✅ Survives session resets
- ✅ Smaller container image
