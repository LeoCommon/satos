################################################################################
#
# satiq
#
################################################################################

SATIQ_SITE = $(BR2_EXTERNAL_SATOS_PATH)/src/satiq-ira
SATIQ_SITE_METHOD = local
SATIQ_LICENSE = GPL-3.0

SATIQ_LICENSE_FILES = README.md LICENSE

SATIQ_SETUP_TYPE = setuptools
SATIQ_DEPENDENCIES = python-crcmod python-pyzmq

#define SATIQ_ADD_PACKAGE_INFO
#		cp $(SATIQ_PKGDIR)/pyproject.toml $(@D)/pyproject.toml
#endef
#SATIQ_POST_CONFIGURE_HOOKS += SATIQ_ADD_PACKAGE_INFO

$(eval $(python-package))
