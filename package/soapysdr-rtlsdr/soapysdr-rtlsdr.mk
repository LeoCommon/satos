################################################################################
#
# soapysdr-rtlsdr
#
################################################################################

SOAPYSDR_RTLSDR_VERSION = b1f568d1b57cc973a1d2ee49be68d0d748d164e4
SOAPYSDR_RTLSDR_SITE = $(call github,pothosware,SoapyRTLSDR,$(SOAPYSDR_RTLSDR_VERSION))
SOAPYSDR_RTLSDR_LICENSE = MIT
SOAPYSDR_RTLSDR_LICENSE_FILES = LICENSE.txt
SOAPYSDR_RTLSDR_DEPENDENCIES = python3 host-swig soapysdr librtlsdr
SOAPYSDR_RTLSDR_INSTALL_STAGING = NO

$(eval $(cmake-package))
