# Docker/Podman build
Inspired by https://github.com/vyos/vyos-build/tree/current/docker

## How to run
Build container image first (from top level of repository)
```
sudo podman build -t satcommon/satos-build:edge docker/
```

### Run builder
```
sudo podman run --rm -it \
    -v "$(pwd)":/satos \
    -v "$HOME/.gitconfig":/etc/gitconfig \
    -w /satos --privileged \
    -e GOSU_UID=$(id -u) -e GOSU_GID=$(id -g) \
    satcommon/satos-build:edge bash
```