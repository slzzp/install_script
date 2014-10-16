#!/bin/sh

# ref: http://apr.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URLAPRUTIL='http://ftp.twaren.net/Unix/Web/apache//apr/apr-util-1.5.4.tar.gz'

BASENAME='/usr/bin/basename'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILEAPRUTIL=`${BASENAME} ${URLAPRUTIL}`
DIRAPRUTIL=`echo -n ${FILEAPRUTIL} | ${SED} 's/\.tar\.gz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILEAPRUTIL}" ]; then
    ${WGET} -4 ${URLAPRUTIL}

    if [ ! -f "${FILEAPRUTIL}" ]; then
        echo "Sorry, can't get ${FILEAPRUTIL} for install apr-util now."
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
if [ -d "${DIRAPRUTIL}" ]; then
    ${RM} -rf ${DIRAPRUTIL}
fi

# unpack source tarball
${TAR} xzvf ${FILEAPRUTIL}

# ----------------------------------------------------------------------

# build and install
cd ${DIRAPRUTIL}

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
