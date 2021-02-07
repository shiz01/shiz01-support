# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools linux-mod linux-info toolchain-funcs udev multilib

DESCRIPTION="High-Performance Intra-Node MPI Communication"
HOMEPAGE="http://knem.gforge.inria.fr/"
if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://gforge.inria.fr/git/knem/knem.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://gitlab.inria.fr/knem/knem/uploads//4a43e3eb860cda2bbd5bf5c7c04a24b6/knem-1.1.4.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2 LGPL-2"
SLOT="0"
IUSE="debug modules"

DEPEND="
		sys-apps/hwloc
		virtual/linux-sources"
RDEPEND="
		sys-apps/hwloc
		sys-apps/kmod[tools]"

MODULE_NAMES="knem(misc:${S}/driver/linux)"
BUILD_TARGETS="all"
BUILD_PARAMS="KDIR=${KERNEL_DIR}"

# PATCHES=( "${FILESDIR}/${P}-setup_timer.patch" )


test_sandbox() {
	has "$1" ${FEATURES} && die "Please disable FEATURE ${1}: -${1}"
}

pkg_pretend() {
	test_sandbox "usersandbox";
}


pkg_setup() {
	linux-info_pkg_setup
	CONFIG_CHECK="DMA_ENGINE"
	check_extra_config
	linux-mod_pkg_setup
	ARCH="$(tc-arch-kernel)"
	ABI="${KERNEL_ABI}"
}

src_prepare() {
	sed 's:driver/linux::g' -i Makefile.am
	eautoreconf
	default
}

src_configure() {
	econf \
		--enable-hwloc \
		--with-linux="${KERNEL_DIR}" \
		--with-linux-release=${KV_FULL} \
		$(use_enable debug)
}

src_compile() {
	default
	if use modules; then
		cd "${S}/driver/linux"
		linux-mod_src_compile || die "failed to build driver"
	fi
}

src_install() {
	default
	if use modules; then
		cd "${S}/driver/linux"
		linux-mod_src_install || die "failed to install driver"
	fi

	# Drop funny unneded stuff
	rm "${ED}/usr/sbin/knem_local_install" || die
	rmdir "${ED}/usr/sbin" || die
	# install udev rules
	udev_dorules "${FILESDIR}/45-knem.rules"
	rm "${ED}/etc/10-knem.rules" || die
}
