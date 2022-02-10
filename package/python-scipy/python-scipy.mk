################################################################################
#
# python-numpy
#
################################################################################

PYTHON_SCIPY_VERSION = 1.8.0
PYTHON_SCIPY_SOURCE = scipy-$(PYTHON_SCIPY_VERSION).tar.gz
PYTHON_SCIPY_SITE = https://github.com/scipy/scipy/releases/download/v$(PYTHON_SCIPY_VERSION)
PYTHON_SCIPY_LICENSE = \
	BSD-3-Clause, \
	BSD-2-Clause, \
	BSD, \
	BSD-Style, \
	Apache-2.0, \
	MIT

PYTHON_SCIPY_LICENSE_FILES = \
	LICENSE.txt \
	scipy/linalg/src/lapack_deprecations/LICENSE \
	scipy/ndimage/LICENSE.txt \
	scipy/optimize/tnc/LICENSE \
	scipy/sparse/linalg/dsolve/SuperLU/License.txt \
	scipy/sparse/linalg/eigen/arpack/ARPACK/COPYING \
	scipy/spatial/qhull_src/COPYING.txt

PYTHON_SCIPY_DEPENDENCIES += \
	host-meson \
	host-python-numpy \
	host-python-pythran \
	lapack \
	openblas \
	python-numpy

PYTHON_SCIPY_INSTALL_STAGING = YES
PYTHON_SCIPY_SETUP_TYPE = setuptools

PYTHON_SCIPY_ENV = \
	F90=$(TARGET_FC) \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS) \
		-L$(PYTHON3_PATH)/site-packages/numpy/core/lib \
		-L$(PYTHON3_PATH)/site-packages/numpy/random/lib" 

# trick to locate 'lapack' and 'blas'
define PYTHON_SCIPY_CONFIGURE_CMDS
	rm -f $(@D)/site.cfg
	echo "[DEFAULT]" >> $(@D)/site.cfg
	echo "library_dirs = $(STAGING_DIR)/usr/lib" >> $(@D)/site.cfg
	echo "include_dirs = $(STAGING_DIR)/usr/include" >> $(@D)/site.cfg
endef

$(eval $(python-package))
