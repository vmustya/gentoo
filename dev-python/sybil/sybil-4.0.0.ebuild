# Copyright 2019-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..11} )

inherit distutils-r1

DESCRIPTION="Automated testing for the examples in your documentation"
HOMEPAGE="
	https://github.com/simplistix/sybil/
	https://pypi.org/project/sybil/
"
SRC_URI="
	https://github.com/simplistix/sybil/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		dev-python/myst_parser[${PYTHON_USEDEP}]
		dev-python/seedir[${PYTHON_USEDEP}]
		dev-python/testfixtures[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
