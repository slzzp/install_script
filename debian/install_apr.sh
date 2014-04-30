#!/bin/sh

# ref: http://apr.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URLAPR='http://ftp.twaren.net/Unix/Web/apache//apr/apr-1.5.0.tar.gz'

BASENAME='/usr/bin/basename'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILEAPR=`${BASENAME} ${URLAPR}`
DIRAPR=`echo -n ${FILEAPR} | ${SED} 's/\.tar\.gz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILEAPR}" ]; then
    ${WGET} -4 ${URLAPR}

    if [ ! -f "${FILEAPR}" ]; then
        echo "Sorry, can't get ${FILEAPR} for install apr now."
        exit
    fi
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIRAPR}" ]; then
    ${RM} -rf ${DIRAPR}
fi

# unpack source tarball
${TAR} xzvf ${FILEAPR}

# ----------------------------------------------------------------------

# build and install
cd ${DIRAPR}

./configure --prefix=/service/apr

${MAKE}
${MAKE} install
