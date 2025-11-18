################################################################################
#
# soapysdr-uhd
#
################################################################################

SOAPYSDR_UHD_VERSION = 2a5d381f68fd05d5b3c0e7db56c36892ea99b4ae
SOAPYSDR_UHD_SITE = $(call github,pothosware,SoapyUHD,$(SOAPYSDR_UHD_VERSION))
SOAPYSDR_UHD_LICENSE = GPL3.0
SOAPYSDR_UHD_LICENSE_FILES = COPYING
SOAPYSDR_UHD_DEPENDENCIES = python3 host-swig soapysdr uhd boost
SOAPYSDR_UHD_INSTALL_STAGING = NO
SOAPYSDR_UHD_CONF_OPTS = -DUHD_ROOT=/usr -DCMAKE_AUTOSET_INSTALL_RPATH=TRUE -DENABLE_TESTS=OFF

$(eval $(cmake-package))
