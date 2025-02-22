################################################################################
#
# LeoCommon client
#
################################################################################

LEOCOMMON_CLIENT_VERSION = 0.2
LEOCOMMON_CLIENT_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/client
LEOCOMMON_CLIENT_SITE_METHOD = local
LEOCOMMON_CLIENT_BUILD_TARGETS = cmd/modem_manager cmd/client
LEOCOMMON_CLIENT_INSTALL_BINS = modem_manager client
LEOCOMMON_CLIENT_LICENSE = GPL-3.0+
LEOCOMMON_CLIENT_LICENSE_FILES = COPYING
LEOCOMMON_CLIENT_DEPENDENCIES=libusb
# Make sure this matches our go.mod file
# Required because auto-discovery is using URLs within buildroot
LEOCOMMON_CLIENT_GOMOD = "github.com/LeoCommon/client"

# Create the required user
# This also adds the client user to the plugdev group so we can use the hackrf
# Furthermore the systemd-journal group is required to access the journal
define LEOCOMMON_CLIENT_USERS
	client -1 client -1 * - - plugdev,systemd-journal client daemon user
endef

# Install the systemd-service and the required policy kit rules
define LEOCOMMON_CLIENT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(@D)/dist/systemd/client.service \
		$(TARGET_DIR)/usr/lib/systemd/system/client.service

	mkdir -p $(TARGET_DIR)/etc/polkit-1/rules.d
	$(INSTALL) -D -m 644 $(@D)/dist/polkit/client.rules \
		$(TARGET_DIR)/etc/polkit-1/rules.d/10-client.rules
endef

$(eval $(golang-package))
