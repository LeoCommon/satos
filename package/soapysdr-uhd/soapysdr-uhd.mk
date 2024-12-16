################################################################################
#
# soapysdr-uhd
#
################################################################################

SOAPYSDR_UHD_VERSION = 1f7b6fa245f782e5d18453f5cbc6d9f27e6b26df
SOAPYSDR_UHD_SITE = $(call github,pothosware,SoapyUHD,$(SOAPYSDR_UHD_VERSION))
SOAPYSDR_UHD_LICENSE = GPL3.0
SOAPYSDR_UHD_LICENSE_FILES = COPYING
SOAPYSDR_UHD_DEPENDENCIES = python3 host-swig soapysdr uhd boost
SOAPYSDR_UHD_INSTALL_STAGING = NO
SOAPYSDR_UHD_CONF_OPTS = -DUHD_ROOT=/usr -DCMAKE_AUTOSET_INSTALL_RPATH=TRUE -DENABLE_TESTS=OFF

$(eval $(cmake-package))
