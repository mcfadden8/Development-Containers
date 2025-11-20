# Development Containers Documentation

Complete documentation for WSL2 + Podman + VSCode development container setup.

**Repository:** https://github.com/mcfadden8/Development-Containers

## Documentation Files

### [SETUP-GUIDE.md](SETUP-GUIDE.md)
Complete installation and configuration guide from scratch. Start here if you're setting up a new Windows 11 machine or haven't configured WSL2 + Podman yet.

**Contents:**
- Prerequisites and system requirements
- WSL2 installation and configuration
- Systemd enablement
- Podman installation
- VSCode setup
- Repository cloning and first container launch
- Step-by-step verification

**When to use:** First-time setup or complete reinstall.

### [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
Daily command reference for working with containers. Keep this handy for common operations.

**Contents:**
- Starting containers
- Container management commands
- Rebuild procedures
- SSH and Git operations
- File access patterns
- Troubleshooting quick fixes
- Useful aliases

**When to use:** Daily development work, quick command lookups.

### [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
Solutions for common problems and error messages.

**Contents:**
- Systemd issues
- Podman socket problems
- Container build errors
- VSCode connection failures
- SSH authentication issues
- History persistence problems
- Performance issues
- Emergency recovery procedures

**When to use:** When something isn't working as expected.

### [SSH-SETUP.md](SSH-SETUP.md)
Comprehensive guide for SSH key management and agent forwarding.

**Contents:**
- SSH key generation
- GitHub/GitLab configuration
- SSH agent auto-start
- Container SSH configuration
- Security considerations
- Multiple keys management
- Advanced SSH config

**When to use:** Setting up SSH, troubleshooting authentication, managing multiple accounts.

## Quick Start

Already have everything installed? Jump right in:

```bash
cd ~/dev
git clone https://github.com/mcfadden8/Development-Containers.git containers
cd containers/spheral-gcc11
mkdir -p ~/.container-data/spheral-gcc11
touch ~/.container-data/spheral-gcc11/.zsh_history
code .
```

In VSCode: `F1` → `Dev Containers: Reopen in Container`

## Documentation Usage

### For New Users

1. Read [SETUP-GUIDE.md](SETUP-GUIDE.md) completely
2. Follow all steps in order
3. Run verification at the end
4. Bookmark [QUICK-REFERENCE.md](QUICK-REFERENCE.md) for daily use
5. Keep [TROUBLESHOOTING.md](TROUBLESHOOTING.md) handy

### For Experienced Users

- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Daily commands
- [SSH-SETUP.md](SSH-SETUP.md) - When setting up new machines
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - When issues arise

### For System Administrators

All documentation is written for individual developer setup, but can be adapted for:
- Team onboarding
- Standard development environments
- CI/CD pipelines
- Shared development servers

## Container Structure

Each container in the repository has:

```
<container-name>/
├── <container-name>.Dockerfile       # Container image definition
├── .devcontainer/
│   └── devcontainer.json            # VSCode Dev Container config
└── verify-setup.sh                  # Setup verification script
```

## Available Containers

### spheral-gcc11

**Purpose:** Spheral physics simulation framework development

**Base:** Ubuntu 22.04 LTS

**Tools:**
- GCC 11.4.0, G++, GFortran
- MPICH 4.1.1
- Python 3.10.12
- Zsh with Oh-My-Zsh
- CMake, Ninja, GDB, Valgrind
- Development utilities

**Workspace:** `/workspaces/spheral-gcc11`

## Creating New Containers

See [SETUP-GUIDE.md](SETUP-GUIDE.md) section "Creating New Containers" for instructions on creating variants.

## Support

### Documentation Issues

If you find errors or have suggestions for documentation:
1. File an issue at: https://github.com/mcfadden8/Development-Containers/issues
2. Include specific documentation file and section

### Setup Problems

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Run `verify-setup.sh` for diagnostic information
3. Check logs as described in troubleshooting guide

### Contributing

Documentation improvements welcome! Standard pull request process:

```bash
cd ~/dev/containers
# Edit documentation files
git add docs/
git commit -m "Docs: Description of changes"
git push origin main
```

## Version Information

This documentation is maintained alongside the container configurations in the repository. Both are version-controlled together to ensure consistency.

Last updated: November 2025

## Additional Resources

- WSL2 Documentation: https://docs.microsoft.com/en-us/windows/wsl/
- Podman Documentation: https://docs.podman.io/
- VSCode Dev Containers: https://code.visualstudio.com/docs/devcontainers/containers
- Repository: https://github.com/mcfadden8/Development-Containers
