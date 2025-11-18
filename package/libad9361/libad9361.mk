################################################################################
#
# libad9361
#
################################################################################

LIBAD9361_VERSION = 0.3
LIBAD9361_SITE = $(call github,analogdevicesinc,libad9361-iio,v$(LIBAD9361_VERSION))
LIBAD9361_INSTALL_STAGING = YES
LIBAD9361_LICENSE = LGPL-2.1+
LIBAD9361_LICENSE_FILES = COPYING.txt
LIBAD9361_CONF_OPTS = -DWITH_DOC=OFF
LIBAD9361_DEPENDENCIES = libiio

$(eval $(cmake-package))
