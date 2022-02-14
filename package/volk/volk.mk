################################################################################
#
# VOLK
#
################################################################################

VOLK_VERSION = 2.5.1
VOLK_SITE = https://github.com/gnuradio/volk/releases/download/v$(VOLK_VERSION)
VOLK_SOURCE = volk-$(VOLK_VERSION).tar.xz
VOLK_LICENSE = GPL-3.0+
VOLK_LICENSE_FILES = README COPYING-LGPL COPYING
VOLK_INSTALL_STAGING = YES
VOLK_DEPENDENCIES += host-python-mako

ifeq ($(BR2_PACKAGE_ORC),y)
VOLK_DEPENDENCIES += orc
VOLK_CONF_OPTS += -DENABLE_ORC=ON
endif

$(eval $(cmake-package))
