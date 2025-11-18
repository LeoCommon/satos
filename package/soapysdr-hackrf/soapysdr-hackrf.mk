################################################################################
#
# soapysdr-uhd
#
################################################################################

SOAPYSDR_HACKRF_VERSION = 143ff5e7e0f786e341df8846c04e8273c5183c26
SOAPYSDR_HACKRF_SITE = $(call github,pothosware,SoapyHackRF,$(SOAPYSDR_HACKRF_VERSION))
SOAPYSDR_HACKRF_LICENSE = GPL3.0
SOAPYSDR_HACKRF_LICENSE_FILES = COPYING
SOAPYSDR_HACKRF_DEPENDENCIES = python3 host-swig soapysdr hackrf boost
SOAPYSDR_HACKRF_INSTALL_STAGING = NO
SOAPYSDR_HACKRF_CONF_OPTS = -DENABLE_TESTS=OFF

$(eval $(cmake-package))
