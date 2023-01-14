################################################################################
#
# satos-genconf
#
################################################################################
SATOS_GENCONF_VERSION = 1.0
SATOS_GENCONF_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/satos_genconf
SATOS_GENCONF_SITE_METHOD = local
SATOS_GENCONF_LICENSE = Proprietary
SATOS_GENCONF_LICENSE_FILES = README.md
SATOS_GENCONF_SETUP_TYPE = setuptools

# This needs to be in sync with the setup.py from satos_genconf
SATOS_GENCONF_DEPENDENCIES = python-dotenv python-jinja2

# Copy over all templates provided by satos-genconf
define SATOS_GENCONF_INSTALL_TEMPLATES
        $(foreach template,$(wildcard $(@D)/templates/*.j2), \
		$(INSTALL) -D -m 0644 $(template) $(TARGET_DIR)/usr/share/satos-genconf/templates/$(notdir $(template))
	)
endef
SATOS_GENCONF_POST_INSTALL_TARGET_HOOKS += SATOS_GENCONF_INSTALL_TEMPLATES

$(eval $(python-package))