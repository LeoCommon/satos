################################################################################
#
# gr-iridium
#
################################################################################

GR_IRIDIUM_VERSION = eed634ca388394fcfd2531187aa77537372519db
GR_IRIDIUM_SITE = $(call github,muccc,gr-iridium,$(GR_IRIDIUM_VERSION))

GR_IRIDIUM_LICENSE = GPL-3.0+

# Theres no real license file, but we include the readme for now <MartB>
GR_IRIDIUM_LICENSE_FILES = README.md
GR_IRIDIUM_DEPENDENCIES = gnuradio host-python3 volk

GR_IRIDIUM_CONF_OPTS = \
	-DENABLE_DEFAULT=OFF \
	-DENABLE_DOXYGEN=OFF

# For third-party blocks, the gr-iridium libraries are mandatory at
# compile time.
GR_IRIDIUM_INSTALL_STAGING = YES

# Fix wrong library suffix
GR_IRIDIUM_CONF_ENV += \
	_PYTHON_SYSCONFIGDATA_NAME=$(PKG_PYTHON_SYSCONFIGDATA_NAME) \
	PYTHONPATH=$(PYTHON3_PATH)

ifeq ($(BR2_PACKAGE_GR_IRIDIUM_PYTHON),y)
GR_IRIDIUM_CONF_OPTS += -DENABLE_PYTHON=ON
GR_IRIDIUM_DEPENDENCIES += python3 python-scipy
else
GR_IRIDIUM_CONF_OPTS += -DENABLE_PYTHON=OFF
endif

$(eval $(cmake-package))
