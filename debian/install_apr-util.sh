#!/bin/sh

# ref: http://apr.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URL_APR_UTIL='http://ftp.twaren.net/Unix/Web/apache//apr/apr-util-1.6.0.tar.gz'

BASENAME='/usr/bin/basename'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILE_APR_UTIL=`${BASENAME} ${URL_APR_UTIL}`
DIR_APR_UTIL=`echo -n ${FILE_APR_UTIL} | ${SED} 's/\.tar\.gz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILE_APR_UTIL}" ]; then
    ${WGET} -4 ${URL_APR_UTIL}

    if [ ! -f "${FILE_APR_UTIL}" ]; then
        echo "Sorry, can't get ${FILE_APR_UTIL} for install apr-util now."
        exit
    fi
fi

# pre-check apr
if [ ! -d '/service/apr' -o ! -f '/service/apr/bin/apr-1-config' ]; then
    echo "Sorry, please install apr first."
    exit
fi

# ----------------------------------------------------------------------

# pre-install libs
if [ ! -f '/usr/share/doc/libssl-dev/copyright' ]; then
    /usr/bin/apt-get -y install libssl-dev
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIR_APR_UTIL}" ]; then
    ${RM} -rf ${DIR_APR_UTIL}
fi

# unpack source tarball
${TAR} xzvf ${FILE_APR_UTIL}

# ----------------------------------------------------------------------

# build and install
cd ${DIR_APR_UTIL}

./configure \
  --prefix=/service/apr-util \
  --with-crypto \
  --with-apr=/service/apr

if [ ! -f 'Makefile' -o ! -f 'test/Makefile' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'apu-config.out' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE} install

if [ ! -f '/service/apr-util/bin/apu-1-config' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi
