################################################################################
#
# LIBVOLK
#
################################################################################

LIBVOLK_VERSION = v2.5.0
LIBVOLK_SITE = https://github.com/gnuradio/volk.git
LIBVOLK_SITE_METHOD = git
LIBVOLK_GIT_SUBMODULES = YES
LIBVOLK_LICENSE = GPL-3.0+
LIBVOLK_LICENSE_FILES = README COPYING-LGPL COPYING
LIBVOLK_INSTALL_STAGING = YES
LIBVOLK_DEPENDENCIES += boost host-python-mako host-python3-six

$(eval $(cmake-package))
