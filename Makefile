# This file is heavily based on https://github.com/home-assistant/operating-system/blob/dev/Makefile
DEPLOYMENT_MODE := dev
BUILDDIR := $(shell pwd)
BUILDROOT = $(BUILDDIR)/buildroot
BUILDROOT_EXTERNAL = $(BUILDDIR)
RELEASE_DIR = $(BUILDDIR)/release
DEFCONFIG_DIR = $(BUILDROOT_EXTERNAL)/configs
TARGET_CONFIG_DIR = $(DEFCONFIG_DIR)/targets/
VERSION_DATE := $(shell date --utc +'%Y%m%d')
VERSION := "$(DEPLOYMENT_MODE)-$(VERSION_DATE)-$(shell git rev-parse --short HEAD)"

# Generate the targets 
TARGETS := $(notdir $(patsubst %.config,%,$(wildcard $(TARGET_CONFIG_DIR)/*.config)))
TARGETS_CONFIG := $(notdir $(patsubst %.config,%-generate,$(wildcard $(TARGET_CONFIG_DIR)/*.config)))

# Set O variable if not already done on the command line
ifneq ("$(origin O)", "command line")
O := $(BUILDDIR)/output
else
override O := $(BUILDDIR)/$(O)
endif

.NOTPARALLEL: $(TARGETS) $(TARGETS_CONFIG) all

.PHONY: $(TARGETS) $(TARGETS_CONFIG) all qemu qemu-dev clean legal apogee help

all: $(TARGETS)

qemu:
	$(MAKE) rpi3_64
	./qemu/run_qemu_rpi3.sh

qemu-dev:
	./qemu/run_qemu_rpi3.sh -k

vscode:
	./scripts/development/prepare-vscode.sh

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

# Generate the required defconfig files and pass them to buildroot
$(TARGETS_CONFIG): %-generate:
	@echo "generating config: configs/targets/$*.config"
	python3 scripts/make_defconfig.py -g configs/targets/$*.config -o configs/$*_defconfig
	@echo "building with config $*_defconfig"
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) "$*_defconfig"

$(TARGETS): %: $(RELEASE_DIR) %-generate
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
	rm -rf configs/*_defconfig

legal:
	# Create legal-info
	rm -rf output/legal-info/
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) legal-info

apogee:
	$(MAKE) -C $(BUILDROOT) O=$(O) BR2_EXTERNAL=$(BUILDROOT_EXTERNAL) apogee-dirclean apogee

help:
	@echo "Supported targets: $(TARGETS)"
	@echo "Run 'make <target>' to build a target image."
	@echo "Run 'make all' to build all target images."
	@echo "Run 'make clean' to clean the build output."
	@echo "Run 'make <target>-config' to configure buildroot for a target."
	@echo "Run 'make qemu' to run the qemu rpi3b emulator in interactive mode"
	@echo "Run 'make qemu-dev' to run the qemu rpi3b emulator in dev mode (keeps all files)."
