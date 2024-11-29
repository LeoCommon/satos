#!/bin/bash
set -e

BUILD_USER="satos_builder"
NEW_UID=$(stat -c "%u" .)
NEW_GID=$(stat -c "%g" .)

# Change effective UID
if [ -n "$GOSU_UID" ]; then
    NEW_UID=$GOSU_UID
fi

# Change effective GID
if [ -n "$GOSU_GID" ]; then
    NEW_GID=$GOSU_GID
fi

export HOME=/home/$BUILD_USER
addgroup --quiet --gid $NEW_GID $BUILD_USER
adduser --quiet --shell /bin/bash -uid $NEW_UID --gid $NEW_GID --home $HOME --disabled-password -gecos "" $BUILD_USER 
adduser --quiet $BUILD_USER sudo

echo "info: fixing user permissions for home directory"
chown $NEW_UID:$NEW_GID /home/$BUILD_USER

if [ "$(id -u)" == "0" ]; then
    exec gosu $BUILD_USER "$@"
fi

# Execute
exec "$@"