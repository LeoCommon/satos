################################################################################
#
# gr-iridium
#
################################################################################

GR_IRIDIUM_VERSION = 2022-02-02_maint-3.9-modified
GR_IRIDIUM_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/gr-iridium
GR_IRIDIUM_SITE_METHOD = local
GR_IRIDIUM_LICENSE = GPL-3.0+

# Theres no real license file, but we include the readme for now <MartB>
GR_IRIDIUM_LICENSE_FILES = README.md

# gr-iridium prevents doing an in-source-tree build
GR_IRIDIUM_SUPPORTS_IN_SOURCE_BUILD = YES

GR_IRIDIUM_DEPENDENCIES = gnuradio host-python3 volk

GR_IRIDIUM_CONF_OPTS = \
	-DENABLE_DEFAULT=OFF \
	-DENABLE_DOXYGEN=OFF

# For third-party blocks, the gr-iridium libraries are mandatory at
# compile time.
GR_IRIDIUM_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_GR_IRIDIUM_PYTHON),y)
GR_IRIDIUM_CONF_OPTS += -DENABLE_PYTHON=ON
GR_IRIDIUM_DEPENDENCIES += python3 python-scipy
else
GR_IRIDIUM_CONF_OPTS += -DENABLE_PYTHON=OFF
endif

$(eval $(cmake-package))
