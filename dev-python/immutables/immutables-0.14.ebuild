# Copyright 2019-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} pypy3 )
inherit distutils-r1

DESCRIPTION="A high-performance immutable mapping type for Python"
HOMEPAGE="https://github.com/MagicStack/immutables"
SRC_URI="https://github.com/MagicStack/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~ppc ~ppc64 x86"

distutils_enable_tests pytest
