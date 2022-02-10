# SATOS
This is the external buildroot tree of SATOS an operating system for satellite (primarily iridium) sniffing.

## How to build
### Cloning the submodules
Make sure you are initializing all submodules used inside of this repository by running
```
git submodule update --init --recursive
```
This will fetch the required dependencies and allow you to run `make`.

### Building using the supplied Makefile
To build the image for a raspberry pi 3 in 64 bit mode use:
```
make rpi3-64
```

### Manual building
If you want to build manually, take a look at how to use the environment variable `BR2_EXTERNAL` in conjunction with the supplied
buildroot tree.

## Get help
Just run `make help` to get a list of all available targets.