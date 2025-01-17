# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom core/pom.xml --download-uri https://github.com/BiglySoftware/BiglyBT/archive/v3.2.0.0.tar.gz --slot 0 --keywords "~amd64" --ebuild biglybt-3.2.0.0.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source"
MAVEN_ID="com.biglybt:biglybt-core:3.1.0.1"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Feature-filled Bittorrent client based on the Azureus open source project"
HOMEPAGE="https://www.biglybt.com"
SRC_URI="https://github.com/BiglySoftware/BiglyBT/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

# Common dependencies
# POM: core/pom.xml
# commons-cli:commons-cli:1.4 -> >=dev-java/commons-cli-1.5.0:1

CP_DEPEND="
	dev-java/commons-cli:1
	dev-java/swt:4.10
"

# Compile dependencies
# POM: core/pom.xml
# org.eclipse.swt:org.eclipse.swt.gtk.linux.x86_64:4.9 -> !!!groupId-not-found!!!
# POM: core/pom.xml
# test? org.assertj:assertj-core:3.12.1 -> !!!suitable-mavenVersion-not-found!!!
# test? org.junit.jupiter:junit-jupiter:5.4.0 -> !!!groupId-not-found!!!

DEPEND="
	>=virtual/jdk-1.8:*
	${CP_DEPEND}
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

DOCS=(
	CODING_GUIDELINES.md
	CONTRIBUTING.md
	ChangeLog.txt
	README.md
	TRANSLATE.md
)

S="${WORKDIR}/BiglyBT-${PV}"

src_prepare() {
	default
	# This directory would break compilation with jdk >= 11
	# "error: package sun.net.spi.nameservice does not exist"
	rm -r core/src/com/biglybt/core/util/spi || die

	cp -r core/{src,resources} || die
	find core/resources -type f -name '*.java' -exec rm -rf {} + || die "deleting classes failed"

	cp -r uis/{src,resources} || die
	find uis/resources -type f -name '*.java' -exec rm -rf {} + || die "deleting classes failed"
}

src_compile() {
	einfo "Compiling module \"core\""
	JAVA_ENCODING="8859_1"
	JAVA_JAR_FILENAME="biglybt-core.jar"
	JAVA_RESOURCE_DIRS="core/resources"
	JAVA_SRC_DIR="core/src"
	java-pkg-simple_src_compile
	JAVA_GENTOO_CLASSPATH_EXTRA="biglybt-core.jar"

	einfo "Compiling module \"uis\""
	JAVA_JAR_FILENAME="BiglyBT.jar"
	JAVA_LAUNCHER_FILENAME="${PN}"
	JAVA_MAIN_CLASS="com.biglybt.ui.Main"
	JAVA_RESOURCE_DIRS="uis/resources"
	JAVA_SRC_DIR="uis/src"
	java-pkg-simple_src_compile

	if use doc; then
		einfo "Compiling javadocs"
		JAVA_SRC_DIR=(
			"core/src"
			"uis/src"
		)
		JAVA_JAR_FILENAME="ignoreme.jar"
		java-pkg-simple_src_compile
	fi
}

src_install() {
	java-pkg_dojar "biglybt-core.jar"
	java-pkg_dojar "BiglyBT.jar"
	java-pkg_dolauncher "biglybt" --main com.biglybt.ui.Main

	if use doc; then
		java-pkg_dojavadoc target/api
	fi

	if use source; then
		java-pkg_dosrc "core/src/*"
		java-pkg_dosrc "uis/src/*"
	fi
	default
}
