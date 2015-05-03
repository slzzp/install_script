#!/bin/sh

PKG='/usr/sbin/pkg'

PKGLIST="\
  sudo \
  perl5 \
  lsof \
  wget \
  rar \
  unzip \
  "

${PKG} update

echo 'y' | ${PKG} install ${PKGLIST}


# for more editor
# echo 'y' | ${PKG} install joe vim

# for postfix
# echo 'y' | ${PKG} install postfix

# for autoconf/automake
# echo 'y' | ${PKG} install autoconf automake

# for php5
# echo 'y' | ${PKG} install php5 php5-iconv php5-xml

# for subversion client/server
# echo 'y' | ${PKG} install subversion

# for git client/server
# echo 'y' | ${PKG} install git tig

# for compat
# echo 'y' | ${PKG} install compat6x-amd64 compat7x-amd64 compat8x-amd64 compat9x-amd64

# for gmake
# echo 'y' | ${PKG} install gmake

# for s3cmd
# echo 'y' | ${PKG} install py27-s3cmd

# for APC ups
# NOTICE: default apcupsd built without snmp driver, if you need snmp to monitor ups, build from ports tree.
# echo 'y' | ${PKG} install apcupsd
