#!/bin/sh

# ref: http://httpd.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URLAPACHE='http://ftp.twaren.net/Unix/Web/apache//httpd/httpd-2.4.9.tar.gz'

BASENAME='/usr/bin/basename'
GREP='/bin/grep'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
TOUCH='/bin/touch'
TR='/usr/bin/tr'
WC='/usr/bin/wc'
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

# pre-check apr
if [ ! -d '/service/apr' -o ! -f '/service/apr/bin/apr-1-config' ]; then
    echo "Sorry, please install apr first."
    exit
fi

# pre-check apr-util
if [ ! -d '/service/apr-util' -o ! -f '/service/apr-util/bin/apu-1-config' ]; then
    echo "Sorry, please install apr-util first."
    exit
fi

# ----------------------------------------------------------------------

# pre-install libs
if [ ! -f '/usr/bin/pcre-config' ]; then
    /usr/bin/apt-get -y install libpcre3 libpcre3-dev libpcre++-dev
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIRAPACHE}" ]; then
    ${RM} -rf ${DIRAPACHE}
fi

# unpack source tarball
${TAR} xzvf ${FILEAPACHE}

# ----------------------------------------------------------------------

# build
cd ${DIRAPACHE}

./configure --prefix=/service/apache2 \
  --enable-rewrite \
  --with-apr=/service/apr \
  --with-apr-util=/service/apr-util

${MAKE}
${MAKE} install

# ----------------------------------------------------------------------

# check setting
CHECKCOUNT=`${GREP} /service/apache2/bin/apachectl /etc/rc.local | ${WC} -l | ${TR} -d ' '`
if [ "0" = "${CHECKCOUNT}" ]; then
    echo 'Activate apache2 in /etc/rc.local'

    ${TOUCH} /etc/rc.local
    echo '/service/apache2/bin/apachectl start &' >> /etc/rc.local
fi

# ----------------------------------------------------------------------

# post-install apache tools
if [ ! -f '/usr/sbin/apachetop' ]; then
    /usr/bin/apt-get -y install apachetop
fi
