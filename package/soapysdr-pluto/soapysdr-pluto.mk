################################################################################
#
# soapysdr-pluto
#
################################################################################

SOAPYSDR_PLUTO_VERSION = cdce23959aca536d5436e0cc689d069a8239f487
SOAPYSDR_PLUTO_SITE = $(call github,pothosware,SoapyPlutoSDR,$(SOAPYSDR_PLUTO_VERSION))
SOAPYSDR_PLUTO_LICENSE = MIT
SOAPYSDR_PLUTO_LICENSE_FILES = LICENSE.txt
SOAPYSDR_PLUTO_DEPENDENCIES = python3 host-swig soapysdr libiio libad9361
SOAPYSDR_PLUTO_INSTALL_STAGING = NO

$(eval $(cmake-package))
