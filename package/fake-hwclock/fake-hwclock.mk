################################################################################
#
# fake-hwclock
#
################################################################################

FAKE_HWCLOCK_VERSION = 5b8105b4b21e70b784140165d0031a9d3865ce65
FAKE_HWCLOCK_SITE = $(call github,xanmanning,alarm-fake-hwclock,$(FAKE_HWCLOCK_VERSION))
FAKE_HWCLOCK_LICENSE_FILES = COPYING

define FAKE_HWCLOCK_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(FAKE_HWCLOCK_PKGDIR)/fake-hwclock.service \
		$(TARGET_DIR)/usr/lib/systemd/system/fake-hwclock.service
	$(INSTALL) -D -m 644 $(FAKE_HWCLOCK_PKGDIR)/fake-hwclock-save.service \
		$(TARGET_DIR)/usr/lib/systemd/system/fake-hwclock-save.service
	$(INSTALL) -D -m 644 $(FAKE_HWCLOCK_PKGDIR)/fake-hwclock-save.timer \
		$(TARGET_DIR)/usr/lib/systemd/system/fake-hwclock-save.timer
endef

define FAKE_HWCLOCK_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

# Use the SOURCE_DATE_EPOCH if the build is reproducible
ifeq ($(BR2_REPRODUCIBLE),y)
FAKEHW_SET_TIME = touch -d @$(SOURCE_DATE_EPOCH)
else
FAKEHW_SET_TIME = touch
endif

# Install the binary and generate an empty fake-hwclock.seed file
# It will have the current build machine timestamp or the reproducible source date stored 
define FAKE_HWCLOCK_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/fake-hwclock $(TARGET_DIR)/usr/bin/fake-hwclock
	$(FAKEHW_SET_TIME) $(TARGET_DIR)/etc/fake-hwclock.seed
endef

$(eval $(generic-package))