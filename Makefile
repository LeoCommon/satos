# This file is heavily based on https://github.com/home-assistant/operating-system/blob/dev/Makefile
DEPLOYMENT_MODE := dev
BUILDDIR := $(shell pwd)
BUILDROOT = $(BUILDDIR)/buildroot
BUILDROOT_EXTERNAL = $(BUILDDIR)
RELEASE_DIR = $(BUILDDIR)/release
DEFCONFIG_DIR = $(BUILDROOT_EXTERNAL)/configs
VERSION_DATE := $(shell date --utc +'%Y%m%d')
VERSION := "$(DEPLOYMENT_MODE)-$(VERSION_DATE)-$(shell git rev-parse --short HEAD)"


TARGETS := $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG := $(notdir $(patsubst %_defconfig,%-config,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))

# Set O variable if not already done on the command line
ifneq ("$(origin O)", "command line")
O := $(BUILDDIR)/output
else
override O := $(BUILDDIR)/$(O)
endif

.NOTPARALLEL: $(TARGETS) $(TARGETS_CONFIG) all

.PHONY: $(TARGETS) $(TARGETS_CONFIG) all qemu qemu-dev clean help

all: $(TARGETS)

qemu:
	$(MAKE) rpi3_64
	./qemu/run_qemu_rpi3.sh

qemu-dev:
	./qemu/run_qemu_rpi3.sh -k

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

$(TARGETS_CONFIG): %-config:
	@echo "config $*"
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) "$*_defconfig"

$(TARGETS): %: $(RELEASE_DIR) %-config
	@echo "build $@"
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) VERSION=$(VERSION)
	mv -f $(O)/images/*.raucb $(RELEASE_DIR)/
	mv -f $(O)/images/sdcard.img $(RELEASE_DIR)/
	# Create a slightly compressed version of sdcard.img
	zstd -T0 -f $(RELEASE_DIR)/sdcard.img

	# Do not clean when building for one target
ifneq ($(words $(filter $(TARGETS),$(MAKECMDGOALS))), 1)
	@echo "clean $@"
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) clean
endif
	@echo "finished $@"

clean:
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) clean

help:
	@echo "Supported targets: $(TARGETS)"
	@echo "Run 'make <target>' to build a target image."
	@echo "Run 'make all' to build all target images."
	@echo "Run 'make clean' to clean the build output."
	@echo "Run 'make <target>-config' to configure buildroot for a target."
	@echo "Run 'make qemu' to run the qemu rpi3b emulator in interactive mode"
	@echo "Run 'make qemu-dev' to run the qemu rpi3b emulator in dev mode (keeps all files)."
