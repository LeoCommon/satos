################################################################################
#
# soapysdr
#
################################################################################

SOAPYSDR_VERSION = c4340a2be0f381f5c68a8898f1b52e19c5428c8c
SOAPYSDR_SITE = $(call github,pothosware,SoapySDR,$(SOAPYSDR_VERSION))
SOAPYSDR_LICENSE = Boost Software License 1.0
SOAPYSDR_LICENSE_FILES = LICENSE_1_0.txt
SOAPYSDR_DEPENDENCIES = python3 host-swig
SOAPYSDR_INSTALL_STAGING = YES
SOAPYSDR_CONF_OPTS = -DENABLE_TESTS=OFF

$(eval $(cmake-package))
