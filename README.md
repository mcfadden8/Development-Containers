# Container Development Environments

WSL2 + Podman + VSCode development containers.

## Containers

- `spheral-gcc11/` - Spheral development with GCC 11, MPICH, Python 3.10, Zsh

## Creating New Container Variants

Use the helper script:
```bash
./scripts/create-container-variant.sh spheral-gcc11 spheral-gcc13
```

This automatically:
- Copies container configuration
- Updates all references
- Creates project and history directories
- Prepares for git commit
