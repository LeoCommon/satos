# Copyright (C) 2024 SatComMon maintainers and contributors

ARG ARCH=
FROM ${ARCH}ubuntu:24.04

LABEL authors="SatComMon Maintainers <maintainers@satcommon.io>" \
      org.opencontainers.image.authors="SatComMon Maintainers <maintainers@satcommon.io>" \
      org.opencontainers.image.url="https://github.com/SatComMon/satos" \
      org.opencontainers.image.documentation="tbd" \
      org.opencontainers.image.source="https://github.com/SatComMon/satos" \
      org.opencontainers.image.vendor="SatComMon" \
      org.opencontainers.image.licenses="GNU" \
      org.opencontainers.image.title="satos-build" \
      org.opencontainers.image.description="Container to build SatOS Images" \
      org.opencontainers.image.base.name="docker.io/ubuntu:24.04"

# Add documentation, graphing and stats tools
ARG DOCUMENTATION_DEPS="asciidoc graphviz python3-matplotlib python3-aiohttp"

# Host dependencies for custom u-boot build
ARG UBOOT_DEPS="libgnutls28-dev uuid-dev libssl-dev"

# Install buildroot essentials https://buildroot.org/downloads/manual/manual.html
RUN apt update && apt install -y --no-install-recommends ${UBOOT_DEPS} ca-certificates \
    locales build-essential which sed make cmake wget binutils diffutils bash patch gzip \
    bzip2 perl tar cpio unzip zstd rsync file bc findutils python3 libncurses-dev curl  \
    cvs git subversion gosu sudo ${DOCUMENTATION_DEPS} openssh-client

# Update locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 

# Remove default ubuntu user
RUN deluser ubuntu 

# Allow everyone in sudo group root access without password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
