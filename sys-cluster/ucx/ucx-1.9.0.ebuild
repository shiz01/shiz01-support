# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Unified Communication X"
HOMEPAGE="https://www.openucx.org"
SRC_URI="https://github.com/openucx/ucx/releases/download/v${PV}/${P}.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="+numa +openmp -java"

RDEPEND="
	sys-libs/binutils-libs:=
	numa? ( sys-process/numactl )
	java? ( fucking/depends )
"

DEPEND="${RDEPEND}"

src_configure() {
	configure_flags=""
	if ! use java; then
		configure_flags+="--without-java"
	fi
	BASE_CFLAGS="" \
	econf ${configure_flags} \
		--disable-compiler-opt \
		$(use_enable numa) \
		$(use_enable openmp)
}

src_compile() {
	BASE_CFLAGS="" emake
}
