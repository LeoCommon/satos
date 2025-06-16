# SATOS

This is the external Buildroot tree of SATOS the **S**atellite data **A**cquisition **T**ool **O**perating **S**ystem.

It is inspired by following excellent projects:

- https://buildroot.org/downloads/manual/manual.html
- https://github.com/cdsteinkuehler/br2rauc
- https://github.com/home-assistant/operating-system

## Cloning the repository submodules

Make sure you are initializing all submodules used inside of this repository by using:

```
git clone https://github.com/LeoCommon/satos.git --recursive
```

when cloning for the first time.

If you forgot, or later want to update submodules for any reason use:

```
git submodule update --init --recursive
```

This will fetch the required dependencies and allow you to run `make`.

## Certificates

The build process generates signed OTA bundles automatically. Therefore, the required development key and certificate must be created in the `ota` directory.

Refer to this example to create your keys.

```
cd ota/

openssl req \
        -subj "/C=DE/ST=Rheinland Pfalz/L=Kaiserslautern/O=satos-dev/CN=satos-dev" \
        -x509 -sha256 -newkey rsa:4096 -nodes -days 365 -keyout dev-key.pem \
        -out dev-ca.pem
```

**Production** mode is not implemented yet, and required a properly setup public key infrastructure with a certificate authority!

## Building

There are two methods to create images. The recommended approach is to use Docker since our provided container ensures that all necessary build dependencies are installed.

### Docker / Podman

The required build container and [instructions to run it are provided in the `docker` subfolder](docker/README.md)

### Manual

Follow [Buildroot getting started](https://buildroot.org/downloads/manual/manual.html#_getting_started). It ensures that the required packages are installed. For a quick starting point check [the apt install steps from our docker file](docker/Dockerfile)

**Limited support will be provided if issues can not be reproduced on our container!**

## Building Images

**The build environment should be installed or you should be in the docker shell at this point.**

To list all available build targets, run `make help`

To build the image for a Raspberry Pi 5 in 64 bit mode use

```
// Run in parallel with all available cores, limit usage using -j NUMBER
make rpi5_64 -j$(nproc)
```

This will provide you with `release/sdcard.img` the image you can flash on the sdcard of your target device and `release/satos-rpi5-64-latest-ota.raucb` which contains OTA update bundles.

The naming sheme for other ota files is `satos-<target>-<mode>-<YYYYMMDD>-<GITREF>-ota.raucb`

### Config adjustments

Config adjustments can be made by first invoking the make command for the specific target, cancelling the build with `CTRL + C` and then executing `make menuconfig` or `make xconfig`. For more specific adjustments refer to the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html)

**Please keep in mind that these config adjustments are temporary, you need to add them to the `configs/fragments/*.confi` files to make them persistent**

## Installation

The resulting `release/sdcard.img` file can be installed onto a SD-Card using the following commands:

```
// (substitute X with your SD Card dev number, usually thats 0)
sudo dd if=release/sdcard.img of=/dev/mmcblkX bs=4M
sync
```

To install the `release\*.raucb` ota bundle files on the device, transfer them to the device and then run `rauc install bundle.raucb`.
