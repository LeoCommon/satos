################################################################################
#
# disco-apogee
#
################################################################################

DISCO_APOGEE_VERSION = 0.1
DISCO_APOGEE_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/apogee
DISCO_APOGEE_SITE_METHOD = local
DISCO_APOGEE_SITE_LICENSE = Proprietary
DISCO_APOGEE_BUILD_TARGETS = cmd/modem_manager
DISCO_APOGEE_INSTALL_BINS = modem_manager

# Make sure this matches our go.mod file
# Required because auto-discovery is using URLs within buildroot
DISCO_APOGEE_GOMOD = "disco.cs.uni-kl.de/apogee"

$(eval $(golang-package))
