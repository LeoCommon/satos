################################################################################
#
# rauc-hawkbit-updater
#
################################################################################

RAUC_HAWKBIT_UPDATER_VERSION = 767a8f8c4dcea8a31385de34d9c03871eaea25cf
RAUC_HAWKBIT_UPDATER_LICENSE = LGPL-2.1 license
RAUC_HAWKBIT_UPDATER_LICENSE_FILES = README.md LICENSE
RAUC_HAWKBIT_UPDATER_SITE = $(call github,rauc,rauc-hawkbit-updater,$(RAUC_HAWKBIT_UPDATER_VERSION))
RAUC_HAWKBIT_UPDATER_DEPENDENCIES = rauc libcurl json-glib

# Disable the documentation
RAUC_HAWKBIT_UPDATER_CONF_OPTS = -Ddoc=disabled -Dapidoc=disabled

# Create the required user for the systemd script
define RAUC_HAWKBIT_UPDATER_USERS
	rauc-hawkbit -1 rauc-hawkbit -1 * - - - RAUC Hawkbit updater user
endef

# Set the correct permissions so the post-install hook can be executed by us
define RAUC_HAWKBIT_UPDATER_PERMISSIONS
	/usr/lib/rauc/postinst.sh f 750 rauc-hawkbit rauc-hawkbit - - - - -
endef

# Enable the systemd integration when its available on our machine
ifeq ($(BR2_INIT_SYSTEMD),y)
RAUC_HAWKBIT_UPDATER_CONF_OPTS += -Dsystemd=enabled	-Dsystemdsystemunitdir=/usr/lib/systemd/system

# Install the systemd-service
define RAUC_HAWKBIT_UPDATER_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(BR2_EXTERNAL_SATOS_PATH)/package/rauc-hawkbit-updater/rauc-hawkbit-updater.service \
		$(TARGET_DIR)/usr/lib/systemd/system/rauc-hawkbit-updater.service
endef
endif

# Install the rauc post installation hook
define RAUC_HAWKBIT_UPDATER_INSTALL_RAUC_HOOK
	$(INSTALL) -m 0550 -D $(BR2_EXTERNAL_SATOS_PATH)/package/rauc-hawkbit-updater/rauc-postinst-hook.sh \
		$(TARGET_DIR)/usr/lib/rauc/postinst.sh
endef
RAUC_HAWKBIT_UPDATER_POST_INSTALL_TARGET_HOOKS += RAUC_HAWKBIT_UPDATER_INSTALL_RAUC_HOOK

$(eval $(meson-package))
