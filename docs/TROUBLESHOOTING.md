# Troubleshooting Guide

Solutions for common issues with WSL2 + Podman + VSCode development containers.

## Systemd Issues

### Problem: "System has not been booted with systemd"

**Cause:** Systemd not enabled in WSL2.

**Solution:**
```bash
sudo vim /etc/wsl.conf
```

Add:
```ini
[boot]
systemd=true
```

Exit and restart WSL:
```bash
exit
```

In PowerShell:
```powershell
wsl --shutdown
wsl
```

Verify:
```bash
systemctl --version
```

## Podman Socket Issues

### Problem: "Cannot connect to Podman socket"

**Cause:** Podman socket not running.

**Solution:**
```bash
systemctl --user start podman.socket
systemctl --user enable podman.socket
systemctl --user status podman.socket
```

Should show "active (listening)".

### Problem: "Permission denied" when accessing socket

**Cause:** User not in correct groups or socket permissions issue.

**Solution:**
```bash
sudo usermod -aG sudo $USER
systemctl --user restart podman.socket
```

Log out and back in, or:
```bash
newgrp sudo
```

## Container Build Issues

### Problem: "No such file or directory: /workspaces/..."

**Cause:** Workspace path mismatch between Dockerfile and devcontainer.json.

**Solution:**

Check Dockerfile `WORKDIR` matches devcontainer.json `workspaceFolder`:

In Dockerfile:
```dockerfile
WORKDIR /workspaces/spheral-gcc11
```

In devcontainer.json:
```json
"workspaceFolder": "/workspaces/spheral-gcc11"
```

### Problem: "OCI runtime attempted to invoke command that was not found"

**Cause:** Command in `postCreateCommand` references incorrect paths or missing tools.

**Solution:**

Check devcontainer.json `postCreateCommand`:
```json
"postCreateCommand": "gcc --version && mpic++ --version && python3 --version && zsh --version"
```

Ensure all commands are installed in Dockerfile.

### Problem: Build hangs at "Running in..." step

**Cause:** Network issues or apt-get waiting for input.

**Solution:**

Ensure `DEBIAN_FRONTEND=noninteractive` in Dockerfile:
```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

Cancel build (`Ctrl+C`), then rebuild with no cache:
```bash
podman build --no-cache -f spheral-gcc11.Dockerfile -t spheral-gcc11:latest ..
```

## VSCode Connection Issues

### Problem: "Cannot connect to container"

**Cause:** Multiple possible issues.

**Solution - Step by step:**

1. Check Podman socket:
```bash
systemctl --user status podman.socket
```

2. Restart socket if needed:
```bash
systemctl --user restart podman.socket
```

3. Check for running containers:
```bash
podman ps -a
```

4. Clean up old containers:
```bash
podman stop $(podman ps -aq) 2>/dev/null || true
podman rm $(podman ps -aq) 2>/dev/null || true
```

5. Rebuild:
```bash
cd ~/dev/containers/spheral-gcc11
code .
```
`F1` → `Dev Containers: Rebuild Container`

### Problem: VSCode settings not persisting

**Cause:** Settings in wrong location.

**Solution:**

Ensure settings are in WSL2 home directory:
```bash
cat ~/.config/Code/User/settings.json
```

Should contain:
```json
{
    "dev.containers.dockerPath": "podman",
    "dev.containers.dockerComposePath": "podman-compose"
}
```

## SSH Issues

### Problem: "Permission denied (publickey)" in container

**Cause:** SSH keys not properly mounted or SSH agent not forwarded.

**Solution:**

1. Verify SSH keys exist in WSL2:
```bash
ls -la ~/.ssh/id_rsa
```

2. Check devcontainer.json has SSH mount:
```json
"mounts": [
    "source=${localEnv:HOME}/.ssh,target=/home/developer/.ssh,type=bind,readonly"
]
```

3. Check SSH agent forwarding:
```json
"runArgs": [
    "--volume=${env:SSH_AUTH_SOCK}:/ssh-agent:z",
    "--env=SSH_AUTH_SOCK=/ssh-agent"
]
```

4. Verify SSH agent running in WSL2:
```bash
echo $SSH_AUTH_SOCK
ssh-add -l
```

5. If not running, add to ~/.zshrc:
```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi
```

### Problem: SSH keys visible but authentication fails

**Cause:** GitHub/GitLab doesn't have your public key.

**Solution:**

1. Copy public key:
```bash
cat ~/.ssh/id_rsa.pub
```

2. Add to GitHub: Settings → SSH and GPG keys → New SSH key

3. Test:
```bash
ssh -T git@github.com
```

## History Issues

### Problem: Shell history not persisting

**Cause:** History file not mounted or doesn't exist.

**Solution:**

1. Create history directory:
```bash
mkdir -p ~/.container-data/spheral-gcc11
touch ~/.container-data/spheral-gcc11/.zsh_history
```

2. Verify devcontainer.json mount:
```json
"mounts": [
    "source=${localEnv:HOME}/.container-data/spheral-gcc11/.zsh_history,target=/home/developer/.zsh_history,type=bind"
]
```

3. Rebuild container

## Git Issues

### Problem: "fatal: could not read Username"

**Cause:** Git not configured in container.

**Solution:**

Configure git inside the container:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Note:** Don't mount `.gitconfig` from host - this causes container crashes.

### Problem: Git operations fail with SSH

**Cause:** SSH keys or agent not properly configured.

**Solution:**

Follow SSH troubleshooting above, then test:
```bash
ssh -T git@github.com
git clone git@github.com:username/test-repo.git
```

## Performance Issues

### Problem: Container is slow

**Cause:** Insufficient WSL2 resources.

**Solution:**

Update `C:\Users\<Username>\.wslconfig`:
```ini
[wsl2]
memory=16GB
processors=8
```

Restart WSL:
```powershell
wsl --shutdown
wsl
```

### Problem: Build takes very long

**Cause:** Network issues or cache not being used.

**Solution:**

1. Use cache when possible (omit `--no-cache`)
2. Check network:
```bash
ping 8.8.8.8
```

3. If network is fine, first build just takes time

## Image Cleanup Issues

### Problem: "zsh: no matches found" when removing images

**Cause:** Zsh trying to expand wildcards.

**Solution:**

Use single quotes:
```bash
podman rmi $(podman images -q --filter 'reference=localhost/vsc-spheral-gcc11*')
```

Or target by ID:
```bash
podman images | grep vsc-spheral-gcc11
podman rmi <image-id>
```

## Workspace Issues

### Problem: Files created in container not visible in WSL2

**Cause:** Working in wrong directory.

**Solution:**

Inside container, work in:
```bash
/workspaces/spheral-gcc11
```

This is mapped to WSL2:
```bash
~/dev/containers/spheral-gcc11
```

### Problem: Changes in WSL2 not visible in container

**Cause:** Container not running or cache issue.

**Solution:**

1. Verify container is running:
```bash
podman ps
```

2. Reload VSCode window:
`F1` → `Developer: Reload Window`

## Emergency Recovery

### Nuclear Option - Complete Reset

If nothing else works:

**In WSL2:**
```bash
podman stop $(podman ps -aq) 2>/dev/null || true
podman rm $(podman ps -aq) 2>/dev/null || true
podman rmi $(podman images -q) 2>/dev/null || true
podman system prune -a -f
rm -rf ~/.vscode-server
systemctl --user restart podman.socket
```

**Rebuild:**
```bash
cd ~/dev/containers/spheral-gcc11
code .
```
`F1` → `Dev Containers: Rebuild Container`

### Full WSL2 Reset

**WARNING: This deletes all WSL2 data!**

Backup important data first!

In PowerShell as Administrator:
```powershell
wsl --shutdown
wsl --unregister Ubuntu-24.04
wsl --install -d Ubuntu-24.04
```

Then follow setup guide from the beginning.

## Getting Help

### Check Logs

**VSCode Dev Containers log:**
`F1` → `Dev Containers: Show Container Log`

**Podman logs:**
```bash
podman logs <container-id>
journalctl --user -u podman.socket
```

**System logs:**
```bash
sudo journalctl -xe
```

### Test Minimal Setup

Create a test container to isolate issues:

```bash
mkdir ~/test-container
cd ~/test-container

cat > Dockerfile << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y vim
EOF

cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Test",
  "build": {
    "dockerfile": "../Dockerfile",
    "context": ".."
  }
}
EOF

podman build -t test:latest .
podman run --rm -it test:latest vim --version
```

If this works, the issue is in your main container configuration.

## Common Configuration Mistakes

1. **Workspace path mismatch** between Dockerfile and devcontainer.json
2. **Missing systemd** in WSL2 configuration
3. **SSH agent not running** in WSL2
4. **Podman socket not enabled** for auto-start
5. **History directory not created** before first run
6. **Mounting `.gitconfig`** (causes crashes - configure git in container instead)
7. **Wrong VSCode settings location** (must be in WSL2 home, not Windows)

## Support Resources

- Repository: https://github.com/mcfadden8/Development-Containers
- WSL2 Documentation: https://docs.microsoft.com/en-us/windows/wsl/
- Podman Documentation: https://docs.podman.io/
- VSCode Dev Containers: https://code.visualstudio.com/docs/devcontainers/containers
