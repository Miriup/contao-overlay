# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit webapp depend.php

DESCRIPTION="Contao is an open source content management system (CMS) that is easy to maintain."
HOMEPAGE="http://www.contao.org/"
SRC_URI="https://github.com/${PN}/core/archive/${PV}.tar.gz -> ${P}.tar.gz
linguas_ar? ( https://contao.org/en/download.html?iso=ar&file=files/languages/ar/Contao-Arabic-v3.zip -> Contao-Arabic-v3.zip )"

LICENSE="LGPL-3"
KEYWORDS="~x86 ~amd64"
LANGS="ar"
IUSE="linguas_ar"

need_php_httpd

DEPEND=""
RDEPEND="
|| ( 
	>=dev-lang/php-5.2[gd,soap,mysql,zlib,xml]
	>=dev-lang/php-5.2[gd-external,soap,mysql,zlib,xml]
	)
>=virtual/mysql-4.1"

S=${WORKDIR}/core-${PV}

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}/system"
	use linguas_ar && unpack Contao-Arabic-v3.zip
}

src_install () {
	webapp_src_preinst

	dodoc README.md

	# 2.10.3 comes with left over session files
	ebegin Removing session files that came with the distribution
	for file in system/tmp/*
	do
		einfo "${file}"
		rm "${file}"
	done
	eend

	insinto "${MY_HTDOCSDIR}"
	doins -r .

	touch "${D}/${MY_HTDOCSDIR}"/system/config/localconfig.php
	webapp_configfile "${MY_HTDOCSDIR}"/system/config/localconfig.php
	webapp_serverowned "${MY_HTDOCSDIR}"/system/config/localconfig.php
	webapp_configfile "${MY_HTDOCSDIR}"/system/config/config.php
	webapp_serverowned "${MY_HTDOCSDIR}"/system/config/config.php

	local dir
	for dir in config logs tmp html scripts
	do
		webapp_serverowned "${MY_HTDOCSDIR}"/system/${dir}
	done

	webapp_serverowned "${MY_HTDOCSDIR}"/templates
	webapp_serverowned "${MY_HTDOCSDIR}"/tl_files

	webapp_src_install
}
