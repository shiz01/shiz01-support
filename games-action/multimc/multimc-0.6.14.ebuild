# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Credit for the main logic and functions:
# https://git.swurl.xyz/PETERIX_ON_SUICIDE_WATCH/multimc-arch-package
# Available as an AUR package:
# https://aur.archlinux.org/packages/multimc-git/

EAPI=7

inherit git-r3 cmake desktop

DESCRIPTION="Minecraft launcher with ability to manage multiple instances."
HOMEPAGE="https://github.com/MultiMC/Launcher"

EGIT_REPO_URI="https://github.com/MultiMC/Launcher https://github.com/MultiMC/libnbtplusplus https://github.com/MultiMC/quazip"

SRC_URI="https://files.multimc.org/downloads/mmc-stable-lin64.tar.gz"

S="${WORKDIR}/${PN}-${PV}"

KEYWORDS="amd64 x86 ~arm64 ~ppc64"

LICENSE="Apache"
SLOT="0"

BDEPEND="virtual/jdk:1.8 media-gfx/inkscape media-gfx/imagemagick media-libs/libicns"
DEPEND="dev-qt/qtcore:5 virtual/jre sys-libs/zlib virtual/opengl"
RDEPEND="${DEPEND}"

_extract_token() {
	pushd ${WORKDIR}/MultiMC/bin > /dev/null
	local token_asm=$(objdump -j '.text' --no-show-raw-insn -C --disassemble='Secrets::getMSAClientID(unsigned char)' MultiMC)
	local token="$(grep -oP '[a-z0-9]{2}(?=,%r[89]d)' <<< ${token_asm} | tac | tr -d '\n')$(grep -oP '(push.+0x)\K[a-z0-9]{2}' <<< ${token_asm} | tac | tr -d '\n')"
	local token_separated="${token:0:8}-${token:8:4}-${token:12:4}-${token:16:4}-${token:20}"
	echo $token_separated
	popd > /dev/null
}

src_unpack() {
	default
	git-r3_src_unpack
}

src_prepare() {
	patch -p1 < "${FILESDIR}/0001-Readd-lin-system-and-LAUNCHER_LINUX_DATADIR.patch"
	patch -p1 < "${FILESDIR}/modern-java.patch"
	patch -p1 < "${FILESDIR}/fix-jars.patch"
	patch -p1 < "${FILESDIR}/mmc-brand.patch"

	local token=$(_extract_token)
	sed -i 's/""/"'"${token}"'"/g' notsecrets/Secrets.cpp

	git checkout 6a4130c9149deb029b496c81e3b874ad834c54b7 -- launcher/resources/{{OSX,flat,iOS,multimc,pe_{blue,colored,dark,light}}/scalable/multimc.svg,multimc/{32x32,128x128}/instances/infinity.png}

	for f in launcher/resources/{OSX,flat,iOS,multimc,pe_{blue,colored,dark,light}}/scalable
	do
	mv "$f/multimc.svg" "$f/launcher.svg"
	done

	cp launcher/resources/multimc/scalable/launcher.svg notsecrets/logo.svg

	git submodule init
	git config submodule.libnbtplusplus.url "${WORKDIR}/libnbtplusplus"
	git config submodule.quazip.url "${WORKDIR}/quazip"
	git submodule update

	default
	cmake_src_prepare
}

src_compile() {
	mkdir -p build

	cd build
	cmake -DCMAKE_BUILD_TYPE=None \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DLauncher_LAYOUT=lin-system \
		-DLauncher_APP_BINARY_NAME="${PN}" \
		-DLauncher_SHARE_DEST_DIR="share/${PN}" \
		-DLauncher_LIBRARY_DEST_DIR="$(get_libdir)" \
		..
	emake

}

src_install() {
	cd "build"
	emake install DESTDIR="${D}"
	cd ..

	newicon "notsecrets/logo.svg" multimc.svg
	domenu "${FILESDIR}/${PN}.desktop"
	#insinto /usr/$(get_libdir)
	#cd build
	#doins "libLauncher_quazip.so"
	#doins "libLauncher_nbt++.so"
}
