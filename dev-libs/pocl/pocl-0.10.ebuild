EAPI="4"
inherit eutils

DESCRIPTION="Portable Computing Language"
HOMEPAGE="http://portablecl.org"
SRC_URI="http://portablecl.org/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="sys-devel/llvm
         sys-devel/clang
         sys-apps/hwloc
         "

DEPEND="${RDEPEND}"

src_configure() {
        econf \
              --disable-icd
}
