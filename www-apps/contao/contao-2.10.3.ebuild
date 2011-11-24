# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit webapp depend.php

DESCRIPTION="Contao is an open source content management system (CMS) for people who want a professional internet presence that is easy to maintain."
HOMEPAGE="http://www.contao.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL"
KEYWORDS="~x86"
IUSE=""

need_php_httpd

DEPEND=""
RDEPEND=">=dev-lang/php-5.2[gd,soap,mysql,zlib,xml]
>=virtual/mysql-4.1"

src_install () {
	webapp_src_preinst

	dodoc INSTALL.txt CHANGELOG.txt
	
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

	webapp_configfile "${MY_HTDOCSDIR}"/system/config/localconfig.php
	webapp_serverowned "${MY_HTDOCSDIR}"/system/config/localconfig.php

	local dir
	for dir in config logs tmp html scripts
	do
		webapp_serverowned "${MY_HTDOCSDIR}"/system/${dir}
	done

	webapp_src_install
}
