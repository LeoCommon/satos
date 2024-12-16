################################################################################
#
# soapysdr
#
################################################################################

SOAPYSDR_VERSION = 8c6cb7c5223fad995e355486527589c63aa3b21e
SOAPYSDR_SITE = $(call github,pothosware,SoapySDR,$(SOAPYSDR_VERSION))
SOAPYSDR_LICENSE = Boost Software License 1.0
SOAPYSDR_LICENSE_FILES = LICENSE_1_0.txt
SOAPYSDR_DEPENDENCIES = python3 host-swig
SOAPYSDR_INSTALL_STAGING = YES
SOAPYSDR_CONF_OPTS = -DENABLE_TESTS=OFF

$(eval $(cmake-package))
