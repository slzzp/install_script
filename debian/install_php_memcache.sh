#!/bin/sh

# This script generates php memcache module

# ref: http://www.php.net/manual/en/memcache.installation.php
#      http://pecl.php.net/package/memcache
URLPHPMEMCACHE='http://pecl.php.net/get/memcache-2.2.7.tgz'

BASENAME='/usr/bin/basename'
CP='/bin/cp'
FIND='/usr/bin/find'
GREP='/bin/grep'
PHPIZE='/service/php/bin/phpize'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
SORT='/usr/bin/sort'
TAIL='/usr/bin/tail'
TAR='/bin/tar'
TR='/usr/bin/tr'
WC='/usr/bin/wc'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILEPHPMEMCACHE=`${BASENAME} ${URLPHPMEMCACHE}`
DIRPHPMEMCACHE=`echo -n ${FILEPHPMEMCACHE} | ${SED} 's/\.tgz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILEPHPMEMCACHE}" ]; then
    ${WGET} -4 ${URLPHPMEMCACHE}

    if [ ! -f "${FILEPHPMEMCACHE}" ]; then
        echo "Sorry, can't get ${FILEPHPMEMCACHE} for install php memcache module now."
        exit
    fi
fi

# check php
if [ ! -d '/service/php' -o ! -d '/service/php/lib/php/extensions' ]; then
    echo "Sorry, please install php first."
    exit
fi

# ----------------------------------------------------------------------

# pre-install libs
if [ ! -f '/usr/bin/autoconf' ]; then
    /usr/bin/apt-get -y install autoconf
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIRPHPMEMCACHE}" ]; then
    ${RM} -rf ${DIRPHPMEMCACHE}
fi

# unpack source tarball
${TAR} xzvf ${FILEPHPMEMCACHE}

# ----------------------------------------------------------------------

# build and install
cd ${DIRPHPMEMCACHE}

${PHPIZE}

./configure \
  --enable-memcache \
  --with-php-config=/service/php/bin/php-config

if [ ! -f 'Makefile' -o ! -f 'config.h' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'modules/memcache.la' -o ! -f 'modules/memcache.so' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi


EXTDIR=`${FIND} /service/php/lib/php/extensions -type d | ${SORT} | ${TAIL} -n 1`

${CP} modules/memcache.so ${EXTDIR}

# copy one more memcache.so for install script check
${CP} modules/memcache.so /service/php/lib/php/extensions/

# ----------------------------------------------------------------------

# check setting
if [ ! -f '/service/php/lib/php.ini' ]; then
    echo 'Activate memcache.so to /service/php/lib/php.ini'

    echo "extension=memcache.so\n" > /service/php/lib/php.ini
else
    EXTLINECOUNT=`${GREP} "extension=memcache.so" /service/php/lib/php.ini | ${WC} -l | ${TR} -d ' '`
    if [ "0" = "${EXTLINECOUNT}" ]; then
        echo 'Activate memcache.so to /service/php/lib/php.ini'

        echo "\nextension=memcache.so\n" >> /service/php/lib/php.ini
    else
        echo 'Activated memcache.so to /service/php/lib/php.ini'
    fi
fi
