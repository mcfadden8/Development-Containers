# Quick Reference Guide

Daily commands and workflows for WSL2 + Podman + VSCode development containers.

## Starting Your Environment

### Open WSL2
```bash
wsl
```

### Navigate and Open Container
```bash
cd ~/dev/containers/spheral-gcc11
code .
```

In VSCode: `F1` → `Dev Containers: Reopen in Container`

## Container Management

### Check Running Containers
```bash
podman ps
```

### Check All Containers (including stopped)
```bash
podman ps -a
```

### Stop Container
```bash
podman stop <container-id>
```

### Remove Container
```bash
podman rm <container-id>
```

### List Images
```bash
podman images
```

### Remove Specific Image
```bash
podman rmi <image-id>
```

### Remove Container-Specific Images
```bash
podman rmi $(podman images -q --filter 'reference=localhost/vsc-spheral-gcc11*')
```

### Clean Up Unused Images
```bash
podman image prune -f
```

### Complete Cleanup
```bash
podman stop $(podman ps -aq) 2>/dev/null || true
podman rm $(podman ps -aq) 2>/dev/null || true
podman image prune -a -f
```

## Rebuilding Containers

### Quick Rebuild (uses cache)
In VSCode: `F1` → `Dev Containers: Rebuild Container`

### Full Rebuild (no cache)
```bash
cd ~/dev/containers/spheral-gcc11
podman rmi $(podman images -q --filter 'reference=localhost/vsc-spheral-gcc11*')
code .
```
Then: `F1` → `Dev Containers: Rebuild Container`

### Manual Build
```bash
cd ~/dev/containers/spheral-gcc11
podman build --no-cache -f spheral-gcc11.Dockerfile -t spheral-gcc11:latest ..
```

## SSH Management

### Check SSH Agent
```bash
echo $SSH_AUTH_SOCK
ssh-add -l
```

### Start SSH Agent (if needed)
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

### Test SSH Connection
```bash
ssh -T git@github.com
```

## Git Operations

### Inside Container
Git is configured to use SSH agent forwarding from WSL2.

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git clone git@github.com:username/repo.git
```

## File Access

### WSL2 from Windows
Navigate in Windows Explorer to:
```
\\wsl$\Ubuntu-24.04\home\<username>\dev\containers
```

### Windows from WSL2
```bash
cd /mnt/c/Users/<WindowsUsername>/Documents
```

### Container Workspace from WSL2
Your workspace is at:
```
~/dev/containers/spheral-gcc11
```

Inside container, it's mounted at:
```
/workspaces/spheral-gcc11
```

## Verification

### Run Verification Script
```bash
cd ~/dev/containers/spheral-gcc11
./verify-setup.sh
```

### Manual Checks
```bash
systemctl --user status podman.socket    # Podman running
podman ps                                 # Containers
ls -la ~/.ssh                            # SSH keys
history | tail                           # History persisting
```

## Container Access

### Open New Terminal in Running Container
In VSCode: `Ctrl+Shift+` ` (backtick)

### Execute Command in Running Container
```bash
podman exec -it <container-name> zsh
```

## Podman Service Management

### Check Socket Status
```bash
systemctl --user status podman.socket
```

### Start Socket
```bash
systemctl --user start podman.socket
```

### Enable Socket (auto-start)
```bash
systemctl --user enable podman.socket
```

### Restart Socket
```bash
systemctl --user restart podman.socket
```

## WSL2 Management

### Shutdown WSL2
In PowerShell:
```powershell
wsl --shutdown
```

### Restart Specific Distribution
```powershell
wsl --terminate Ubuntu-24.04
wsl -d Ubuntu-24.04
```

### Check WSL Status
```powershell
wsl --list --verbose
```

## Troubleshooting Quick Fixes

### Container Won't Start
```bash
systemctl --user restart podman.socket
cd ~/dev/containers/spheral-gcc11
code .
```

### Permission Issues
```bash
podman system prune -a -f
systemctl --user restart podman.socket
```

### VSCode Connection Issues
1. Close all VSCode windows
2. In WSL2: `systemctl --user restart podman.socket`
3. Open VSCode: `code ~/dev/containers/spheral-gcc11`
4. Rebuild container

### History Not Persisting
Check history file exists:
```bash
ls -la ~/.container-data/spheral-gcc11/.zsh_history
```

Create if missing:
```bash
mkdir -p ~/.container-data/spheral-gcc11
touch ~/.container-data/spheral-gcc11/.zsh_history
```

## Environment Variables

### Inside Container
```bash
echo $CC              # /usr/bin/gcc-11 (or your default)
echo $CXX             # /usr/bin/g++-11
echo $PATH            # Includes /home/developer/.local/bin
```

## Useful Aliases

Add to `~/.zshrc` in WSL2:

```bash
alias dcp='cd ~/dev/containers/spheral-gcc11'
alias dcopen='cd ~/dev/containers/spheral-gcc11 && code .'
alias podman-clean='podman stop $(podman ps -aq) 2>/dev/null; podman rm $(podman ps -aq) 2>/dev/null; podman image prune -f'
```

## Repository Management

### Update from GitHub
```bash
cd ~/dev/containers
git pull origin main
```

### Commit Changes
```bash
cd ~/dev/containers
git add .
git commit -m "Description of changes"
git push origin main
```

## Common Workflows

### Start of Day
```bash
wsl
cd ~/dev/containers/spheral-gcc11
code .
```
In VSCode: `F1` → `Dev Containers: Reopen in Container`

### End of Day
Exit container terminal, close VSCode. Container stops automatically.

### After System Updates
```bash
wsl --shutdown
wsl
systemctl --user restart podman.socket
cd ~/dev/containers/spheral-gcc11
code .
```

### Switching Containers
Close current VSCode window, then:
```bash
cd ~/dev/containers/<other-container>
code .
```
