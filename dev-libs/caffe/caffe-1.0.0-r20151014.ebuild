EAPI="5"

inherit git-r3

DESCRIPTION="caffe deep learning framework"
HOMEPAGE="http://caffe.berkeleyvision.org/"
LICENSE="BSD"
EGIT_REPO_URI="git://github.com/BVLC/caffe.git"
EGIT_COMMIT="8c8e832e71985ba89dcb7c8a60697322c54b5f5b"
EGIT_CLONE_TYPE="single"

KEYWORDS="amd64 amd64-linux"
SLOT="1/${PV}"

DEPEND=">=dev-libs/boost-1.55
		dev-cpp/glog
		dev-db/lmdb
		app-arch/snappy
		sci-libs/hdf5
		dev-libs/leveldb
		dev-libs/protobuf
		dev-cpp/gflags
		atlas? ( sci-libs/atlas )"

RDEPEND="${DEPEND}"

IUSE="atlas"

src_configure() {
		cp Makefile.config.example Makefile.config
		#sed 's@^# CPU_ONLY := 1$@CPU_ONLY := 1@' -i Makefile.config
}

src_compile() {
		CXX="g++ -static" emake
}

src_install() {
		mkdir -p "${ED}"/usr/bin
		tar -C .build_release -c lib | tar -C "${ED}/usr" -x
		cp .build_release/tools/caffe.bin "${ED}"/usr/bin
}
