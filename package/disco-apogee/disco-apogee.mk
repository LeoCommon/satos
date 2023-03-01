################################################################################
#
# disco-apogee
#
################################################################################

DISCO_APOGEE_VERSION = 0.3
DISCO_APOGEE_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/apogee
DISCO_APOGEE_SITE_METHOD = local
DISCO_APOGEE_SITE_LICENSE = Proprietary
DISCO_APOGEE_BUILD_TARGETS = cmd/modem_manager cmd/apogee-client
DISCO_APOGEE_INSTALL_BINS = modem_manager apogee-client

# Make sure this matches our go.mod file
# Required because auto-discovery is using URLs within buildroot
DISCO_APOGEE_GOMOD = "disco.cs.uni-kl.de/apogee"

# Create the required user
# This also adds the apogee user to the plugdev group so we can use the hackrf
# Furthermore the systemd-journal group is required to access the journal
define DISCO_APOGEE_USERS
	apogee -1 apogee -1 * - - plugdev,systemd-journal Apogee daemon user
endef

# Install the systemd-service and the required policy kit rules
define DISCO_APOGEE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(DISCO_APOGEE_PKGDIR)/apogee-client.service \
		$(TARGET_DIR)/usr/lib/systemd/system/apogee-client.service

	mkdir -p $(TARGET_DIR)/etc/polkit-1/rules.d
	$(INSTALL) -D -m 644 $(DISCO_APOGEE_PKGDIR)disco-apogee.rules \
		$(TARGET_DIR)/etc/polkit-1/rules.d/10-disco-apogee.rules
endef

$(eval $(golang-package))
