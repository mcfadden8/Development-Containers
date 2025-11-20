# SSH Configuration for Development Containers

Complete guide for SSH key management and agent forwarding in WSL2 + Podman + VSCode environments.

## Overview

SSH configuration has three components:
1. **SSH keys** in WSL2 (`~/.ssh`)
2. **SSH agent** running in WSL2
3. **SSH agent forwarding** to containers

## Architecture

```
Windows
  └─> WSL2 (Ubuntu)
       ├─> SSH Keys (~/.ssh/)
       ├─> SSH Agent (running)
       └─> Container
            ├─> SSH Keys (mounted readonly from WSL2)
            └─> SSH Agent Socket (forwarded from WSL2)
```

## Initial SSH Key Setup

### Generate SSH Key (if needed)

In WSL2:
```bash
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

Accept defaults or customize:
- File: `~/.ssh/id_rsa` (default)
- Passphrase: (recommended but optional)

### Add Public Key to Services

#### GitHub
```bash
cat ~/.ssh/id_rsa.pub
```

1. Copy output
2. Go to https://github.com/settings/keys
3. Click "New SSH key"
4. Paste and save

Test:
```bash
ssh -T git@github.com
```

#### GitLab
```bash
cat ~/.ssh/id_rsa.pub
```

1. Copy output
2. Go to https://gitlab.com/-/profile/keys
3. Paste and add

Test:
```bash
ssh -T git@gitlab.com
```

## SSH Agent Configuration

### Auto-Start SSH Agent in WSL2

Add to `~/.zshrc` (or `~/.bashrc`):

```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi
```

Apply changes:
```bash
source ~/.zshrc
```

### Verify SSH Agent

```bash
echo $SSH_AUTH_SOCK
```
Should show a path like: `/tmp/ssh-XXXXXX/agent.XXXXX`

```bash
ssh-add -l
```
Should list your SSH key(s).

### Manual SSH Agent Operations

Start agent:
```bash
eval "$(ssh-agent -s)"
```

Add key:
```bash
ssh-add ~/.ssh/id_rsa
```

List keys:
```bash
ssh-add -l
```

Remove all keys:
```bash
ssh-add -D
```

## Container SSH Configuration

### devcontainer.json Configuration

Your devcontainer.json should include:

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.ssh,target=/home/developer/.ssh,type=bind,readonly"
  ],
  "runArgs": [
    "--volume=${env:SSH_AUTH_SOCK}:/ssh-agent:z",
    "--env=SSH_AUTH_SOCK=/ssh-agent"
  ]
}
```

**Key points:**
- SSH directory mounted **readonly** (prevents accidental modification)
- SSH_AUTH_SOCK forwarded to `/ssh-agent` in container
- Environment variable set so SSH client finds the agent

### Why This Works

1. **Keys mounted readonly:** Provides read access to SSH keys without copying
2. **Agent forwarded:** Container uses WSL2's SSH agent, avoiding key duplication
3. **No key management in container:** Keys stay in WSL2, container just uses them

## Verification

### In WSL2

```bash
ls -la ~/.ssh
echo $SSH_AUTH_SOCK
ssh-add -l
```

Should show:
- SSH directory with keys
- SSH_AUTH_SOCK set
- Keys loaded in agent

### In Container

```bash
ls -la ~/.ssh
echo $SSH_AUTH_SOCK
ssh-add -l
```

Should show:
- Same SSH keys visible
- SSH_AUTH_SOCK pointing to `/ssh-agent`
- Same keys listed

### Test SSH Operations

In container:
```bash
ssh -T git@github.com
git clone git@github.com:username/repo.git
```

Should work without password (or with passphrase if key is encrypted).

## Security Considerations

### Why Readonly Mount?

Mounting SSH keys readonly:
- Prevents accidental modification from container
- Reduces attack surface
- Follows principle of least privilege

### SSH Agent vs. Key Copying

**SSH Agent Forwarding (recommended):**
- ✅ Keys stay in WSL2 only
- ✅ Single source of truth
- ✅ Revoke once, affects all containers
- ✅ No key duplication

**Key Copying (not recommended):**
- ❌ Keys duplicated in container
- ❌ Multiple copies to manage
- ❌ Security risk if container compromised
- ❌ More complex revocation

### Multiple Keys

If you have multiple SSH keys:

```bash
vim ~/.ssh/config
```

Add:
```
Host github.com
    IdentityFile ~/.ssh/id_rsa_github

Host gitlab.com
    IdentityFile ~/.ssh/id_rsa_gitlab
```

Add both keys to agent:
```bash
ssh-add ~/.ssh/id_rsa_github
ssh-add ~/.ssh/id_rsa_gitlab
```

## Troubleshooting

### Problem: "Permission denied (publickey)"

**Check in WSL2:**
```bash
ls -la ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

**Check agent:**
```bash
ssh-add -l
```

If empty:
```bash
ssh-add ~/.ssh/id_rsa
```

**Check public key on service:**
```bash
cat ~/.ssh/id_rsa.pub
```

Verify this matches the key on GitHub/GitLab.

### Problem: Agent not forwarding to container

**Check devcontainer.json:**

Ensure runArgs includes:
```json
"--volume=${env:SSH_AUTH_SOCK}:/ssh-agent:z",
"--env=SSH_AUTH_SOCK=/ssh-agent"
```

**Rebuild container:**
```bash
code .
```
`F1` → `Dev Containers: Rebuild Container`

### Problem: "Could not open a connection to your authentication agent"

**In WSL2:**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

**Check ~/.zshrc:**

Ensure auto-start configuration is present and sourced.

### Problem: Passphrase required every time

**Option 1 - Add to agent permanently:**

In WSL2 `~/.ssh/config`:
```
Host *
    AddKeysToAgent yes
```

**Option 2 - Use ssh-agent with persistence:**

Add to ~/.zshrc:
```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
    if [ -f ~/.ssh/agent.env ]; then
        source ~/.ssh/agent.env > /dev/null
        if ! kill -0 $SSH_AGENT_PID 2>/dev/null; then
            eval "$(ssh-agent -s)" > /dev/null
            echo "SSH_AGENT_PID=$SSH_AGENT_PID; export SSH_AGENT_PID" > ~/.ssh/agent.env
            echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AUTH_SOCK" >> ~/.ssh/agent.env
        fi
    else
        eval "$(ssh-agent -s)" > /dev/null
        echo "SSH_AGENT_PID=$SSH_AGENT_PID; export SSH_AGENT_PID" > ~/.ssh/agent.env
        echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AUTH_SOCK" >> ~/.ssh/agent.env
    fi
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi
```

## Multiple Containers

All containers share the same SSH setup:
- Keys mounted from `~/.ssh` (same source)
- Agent forwarded from WSL2 (same agent)

No per-container configuration needed!

## Best Practices

1. **Use SSH agent forwarding** instead of copying keys
2. **Mount SSH directory readonly** for security
3. **Keep keys in WSL2 only** - don't duplicate
4. **Use ~/.ssh/config** for complex host configurations
5. **Test SSH before git operations** with `ssh -T git@github.com`
6. **Protect private keys** with appropriate permissions (600)
7. **Use passphrases** for additional security
8. **Rotate keys periodically** and revoke old ones

## Advanced: SSH Config Examples

### Multiple GitHub Accounts

`~/.ssh/config`:
```
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_work

Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_personal
```

Clone work repos:
```bash
git clone git@github-work:company/repo.git
```

Clone personal repos:
```bash
git clone git@github-personal:username/repo.git
```

### SSH Multiplexing

Speeds up repeated connections:

`~/.ssh/config`:
```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

Create socket directory:
```bash
mkdir -p ~/.ssh/sockets
```

### Verbose Debugging

```bash
ssh -vvv git@github.com
```

Shows detailed connection information for troubleshooting.

## Summary

**Working configuration checklist:**
- ✅ SSH keys in `~/.ssh` with correct permissions
- ✅ Public key added to GitHub/GitLab
- ✅ SSH agent auto-starts in WSL2
- ✅ Keys loaded in agent (`ssh-add -l`)
- ✅ devcontainer.json mounts SSH readonly
- ✅ devcontainer.json forwards SSH_AUTH_SOCK
- ✅ Test successful: `ssh -T git@github.com`

With this setup, all containers automatically have SSH access without any key management overhead!
