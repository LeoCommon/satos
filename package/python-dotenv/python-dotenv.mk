################################################################################
#
# python-dotenv
#
################################################################################
PYTHON_DOTENV_VERSION = 0.21.0
PYTHON_DOTENV_SOURCE = python-dotenv-$(PYTHON_DOTENV_VERSION).tar.gz
PYTHON_DOTENV_SITE = https://files.pythonhosted.org/packages/87/8d/ab7352188f605e3f663f34692b2ed7457da5985857e9e4c2335cd12fb3c9
PYTHON_DOTENV_SETUP_TYPE = setuptools
PYTHON_DOTENV_LICENSE = BSD-3-Clause
PYTHON_DOTENV_LICENSE_FILES = LICENSE

$(eval $(python-package))
