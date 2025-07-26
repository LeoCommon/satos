# Docker build

Inspired by https://github.com/vyos/vyos-build/tree/current/docker

## Prepare container image

Build container image first (from top level of repository)

```
sudo docker build -t leocommon/builder:edge docker/
```

## Run builder

```
sudo docker run --rm -it \
    -v "$(pwd)":/satos \
    -v "$HOME/.gitconfig":/etc/gitconfig \
    -w /satos \
    -e GOSU_UID=$(id -u) -e GOSU_GID=$(id -g) \
    leocommon/builder:edge bash
```

Then follow the usual build steps, all required tools are pre-installed on the container.
