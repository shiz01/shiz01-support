# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Minimalistic C client library for the Redis database"
HOMEPAGE="https://github.com/redis/hiredis"
SRC_URI="https://github.com/redis/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/1.0.0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ppc ppc64 ~riscv ~s390 sparc x86 ~x64-solaris"
IUSE="examples ssl test"
RESTRICT="!test? ( test )"

DEPEND="ssl? ( dev-libs/openssl:= )"
RDEPEND="${RDEPEND}"
BDEPEND="test? ( dev-db/redis )"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.0-disable-network-tests.patch
)

src_configure() {
	local mycmakeargs=(
		-DENABLE_SSL=$(usex ssl)
		-DENABLE_EXAMPLES=$(usex examples)
		-DDISABLE_TESTS=$(usex !test)
	)

	if use test; then
		mycmakeargs+=( -DENABLE_SSL_TESTS=$(usex test) )
	fi

	cmake_src_configure
}

