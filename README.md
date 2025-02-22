# SATOS
This is the external Buildroot tree of SATOS the Satellite data Acquisition Tool Operating System. https://buildroot.org/downloads/manual/manual.html

It is inspired by following excellent projects:
- https://github.com/cdsteinkuehler/br2rauc
- https://github.com/home-assistant/operating-system

## How to build
Follow [Buildroot getting started](https://buildroot.org/downloads/manual/manual.html#_getting_started). It ensures that the required packages are installed. 
### Cloning all submodules
Make sure you are initializing all submodules used inside of this repository by running
```
git submodule update --init --recursive
```
This will fetch the required dependencies and allow you to run `make`, if there are any errors check that you have access to the projects listed in `.gitmodules`.

### Certificates
The build process generates signed OTA bundles automatically. Therefore, the required development key and certificate must be created in the `ota` directory.

```
cd ota/

openssl req \
        -subj "/C=DE/ST=Rheinland Pfalz/L=Kaiserslautern/O=satos-dev/CN=satos-dev" \
        -x509 -sha256 -newkey rsa:4096 -nodes -days 365 -keyout dev-key.pem \
        -out dev-ca.pem 
```

**Production** mode is not implemented yet, and required a properly setup public key infrastructure with a certificate authority!


### Building using the supplied Makefile
To build the image for a raspberry pi 5 in 64 bit mode use:
```
make rpi5-64
```

To list all available targets, run `make help`.

### Manual building
If you want to build manually, take a look at how to use the environment variable `BR2_EXTERNAL` in conjunction with the supplied
buildroot tree. 

#### Config adjustments
Config adjustments can be made by first invoking the make command for the specific target, cancelling the build with `CTRL + C` and then executing `make menuconfig` or `make xconfig`. For more specific adjustments refer to the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html)

## Installation
The resulting image can be installed onto a SD-Card using the following commands
```
// (substitute X with your SD Card mount point, usually thats 0)
sudo dd if=release/sdcard.img of=/dev/mmcblkX bs=4M
sync
```
