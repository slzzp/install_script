#!/bin/sh

# ref: http://apr.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URL_APR='http://ftp.twaren.net/Unix/Web/apache//apr/apr-1.5.2.tar.gz'

BASENAME='/usr/bin/basename'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILE_APR=`${BASENAME} ${URL_APR}`
DIR_APR=`echo -n ${FILE_APR} | ${SED} 's/\.tar\.gz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILE_APR}" ]; then
    ${WGET} -4 ${URL_APR}

    if [ ! -f "${FILE_APR}" ]; then
        echo "Sorry, can't get ${FILE_APR} for install apr now."
        exit
    fi
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIR_APR}" ]; then
    ${RM} -rf ${DIR_APR}
fi

# unpack source tarball
${TAR} xzvf ${FILE_APR}

# ----------------------------------------------------------------------

# build and install
cd ${DIR_APR}

./configure \
  --prefix=/service/apr

if [ ! -f 'Makefile' -o ! -f 'test/Makefile' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'build/apr_rules.out' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE} install

if [ ! -f '/service/apr/bin/apr-1-config' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi
