# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools multilib-minimal

MY_P=sidplay-libs-${PV}

DESCRIPTION="C64 SID player library"
HOMEPAGE="http://sidplay2.sourceforge.net/"
SRC_URI="mirror://sourceforge/sidplay2/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv sparc x86"
IUSE="static-libs"

BDEPEND="sys-devel/autoconf-archive"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/sidplay/sidconfig.h
)

PATCHES=(
	"${FILESDIR}"/${P}-gcc41.patch
	"${FILESDIR}"/${P}-fbsd.patch
	"${FILESDIR}"/${P}-gcc43.patch
	"${FILESDIR}"/${P}-no_libtool_reference.patch
	"${FILESDIR}"/${P}-gcc6.patch
	"${FILESDIR}"/${P}-autoconf.patch
	"${FILESDIR}"/${P}-slibtool.patch
	"${FILESDIR}"/${P}-clang16.patch
)

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	local subdirs=(
		builders/hardsid-builder
		builders/resid-builder
		libsidplay
		libsidutils
		resid
		.
	)

	for i in ${subdirs[@]}; do
		(
			cd "$i" || die
			eautoreconf
		)
	done

	multilib_copy_sources
}

multilib_src_configure() {
	local myeconfargs=(
		--enable-shared
		--with-pic
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	docinto libsidplay
	dodoc libsidplay/{AUTHORS,ChangeLog,README,TODO}

	docinto libsidutils
	dodoc libsidutils/{AUTHORS,ChangeLog,README,TODO}

	docinto resid
	dodoc resid/{AUTHORS,ChangeLog,NEWS,README,THANKS,TODO}

	doenvd "${FILESDIR}"/65resid

	find "${D}" -name '*.la' -delete || die
}
