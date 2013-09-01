#!/bin/sh

# ref: http://httpd.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URLAPACHE='http://ftp.twaren.net/Unix/Web/apache//httpd/httpd-2.4.6.tar.gz'

BASENAME='/usr/bin/basename'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILEAPACHE=`${BASENAME} ${URLAPACHE}`
DIRAPACHE=`echo -n ${FILEAPACHE} | ${SED} 's/\.tar\.gz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILEAPACHE}" ]; then
    ${WGET} -4 ${URLAPACHE}

    if [ ! -f "${FILEAPACHE}" ]; then
        echo "Sorry, can't get ${FILEAPACHE} for install apache now."
        exit
    fi
fi

# remove old directory
if [ -d "${DIRAPACHE}" ]; then
    ${RM} -rf ${DIRAPACHE}
fi

# unpack source tarball
${TAR} xzvf ${FILEAPACHE}


# build
cd ${DIRAPACHE}

./configure --prefix=/service/apache2 \
  --with-apr=/service/apr \
  --with-apr-util=/service/apr-util

${MAKE}
${MAKE} install
