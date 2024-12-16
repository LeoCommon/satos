################################################################################
#
# soapysdr-uhd
#
################################################################################

SOAPYSDR_HACKRF_VERSION = 6c0c33f0aa44c3080674e6bca0273184d3e9eb44
SOAPYSDR_HACKRF_SITE = $(call github,pothosware,SoapyHackRF,$(SOAPYSDR_HACKRF_VERSION))
SOAPYSDR_HACKRF_LICENSE = GPL3.0
SOAPYSDR_HACKRF_LICENSE_FILES = COPYING
SOAPYSDR_HACKRF_DEPENDENCIES = python3 host-swig soapysdr hackrf boost
SOAPYSDR_HACKRF_INSTALL_STAGING = NO
SOAPYSDR_HACKRF_CONF_OPTS = -DENABLE_TESTS=OFF

$(eval $(cmake-package))
