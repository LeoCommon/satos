# Copyright (C) 2024-2025 LeoCommon maintainers and contributors

ARG ARCH=
FROM ${ARCH}debian:12

LABEL authors="LeoCommon Maintainers <contact@martb.dev>" \
      org.opencontainers.image.authors="LeoCommon Maintainers <contact@martb.dev>" \
      org.opencontainers.image.url="https://github.com/LeoCommon/satos" \
      org.opencontainers.image.documentation="tbd" \
      org.opencontainers.image.source="https://github.com/LeoCommon/satos" \
      org.opencontainers.image.vendor="LeoCommon" \
      org.opencontainers.image.licenses="GNU" \
      org.opencontainers.image.title="satos-build" \
      org.opencontainers.image.description="Container to build SatOS Images" \
      org.opencontainers.image.base.name="docker.io/debian:12"

# Add documentation, graphing and stats tools
ARG DOCUMENTATION_DEPS="asciidoc graphviz python3-matplotlib python3-aiohttp"

# Host dependencies for custom u-boot build
ARG UBOOT_DEPS="libgnutls28-dev uuid-dev libssl-dev"

# Install buildroot essentials https://buildroot.org/downloads/manual/manual.html
RUN apt update && apt install -y --no-install-recommends ${UBOOT_DEPS} ca-certificates \
    locales build-essential which sed make wget binutils diffutils bash patch gzip \
    bzip2 perl tar cpio unzip zstd rsync file bc findutils python3 libncurses-dev curl  \
    cvs git subversion gosu sudo ${DOCUMENTATION_DEPS} openssh-client libelf-dev nano btop

# Update locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 
ENV LANG=en_US.UTF-8 

# Allow everyone in sudo group root access without password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
