# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit webapp

DESCRIPTION="Contao is an open source content management system (CMS) that is easy to maintain."
HOMEPAGE="http://www.contao.org/"
SRC_URI="https://github.com/${PN}/core/archive/${PV%_p1}.tar.gz -> ${P%_p1}.tar.gz
https://github.com/contao-community-alliance/contao-core-hotfix/archive/securityfix-${PV%_p1}-patchset.zip
linguas_ar? ( https://contao.org/en/download.html?iso=ar&file=files/languages/ar/Contao-Arabic-v3.zip -> Contao-Arabic-v3.zip )"

LICENSE="LGPL-3"
KEYWORDS="~x86 ~amd64"
LANGS="ar"
IUSE="linguas_ar"

DEPEND=""
RDEPEND="
|| ( 
	>=dev-lang/php-5.2[gd,soap,mysqli,zlib,xml]
	>=dev-lang/php-5.2[gd-external,soap,mysqli,zlib,xml]
	)
>=virtual/mysql-4.1"

need_httpd

S=${WORKDIR}/core-${PV%_p1}

src_unpack() {
	unpack ${P%_p1}.tar.gz
	unpack securityfix-${PV%_p1}-patchset.zip
	cd "${S}/system"
	use linguas_ar && unpack Contao-Arabic-v3.zip
}

src_prepare() {
	ebegin Patching ${PV%_p1} installation
		pushd ${WORKDIR}/contao-core-hotfix-securityfix-${PV%_p1}-patchset
		find . -type f | while read file
		do
			mv "${file}" "${S}/${file#./}"
		done
		popd
	eend
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
	#webapp_configfile "${MY_HTDOCSDIR}"/system/config/config.php
	#webapp_serverowned "${MY_HTDOCSDIR}"/system/config/config.php

	local dir
	for dir in config logs tmp html scripts modules drivers
	do
		webapp_serverowned "${MY_HTDOCSDIR}"/system/${dir}
	done

	webapp_serverowned "${MY_HTDOCSDIR}"/plugins
	webapp_serverowned "${MY_HTDOCSDIR}"/templates
	webapp_serverowned "${MY_HTDOCSDIR}"/tl_files

	webapp_src_install
}
