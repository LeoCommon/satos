################################################################################
#
# apogee
#
################################################################################

APOGEE_VERSION = 0.2
APOGEE_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/apogee
APOGEE_SITE_METHOD = local
APOGEE_BUILD_TARGETS = cmd/modem_manager cmd/client
APOGEE_INSTALL_BINS = modem_manager client
APOGEE_LICENSE = GPL-3.0+
APOGEE_LICENSE_FILES = COPYING
APOGEE_DEPENDENCIES=libusb
# Make sure this matches our go.mod file
# Required because auto-discovery is using URLs within buildroot
APOGEE_GOMOD = "disco.cs.uni-kl.de/apogee"

# Create the required user
# This also adds the apogee user to the plugdev group so we can use the hackrf
# Furthermore the systemd-journal group is required to access the journal
define APOGEE_USERS
	apogee -1 apogee -1 * - - plugdev,systemd-journal Apogee daemon user
endef

# Install the systemd-service and the required policy kit rules
define APOGEE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(@D)/dist/systemd/client.service \
		$(TARGET_DIR)/usr/lib/systemd/system/client.service

	mkdir -p $(TARGET_DIR)/etc/polkit-1/rules.d
	$(INSTALL) -D -m 644 $(@D)/dist/polkit/client.rules \
		$(TARGET_DIR)/etc/polkit-1/rules.d/10-client.rules
endef

$(eval $(golang-package))
