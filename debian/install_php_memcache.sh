#!/bin/sh

# This script generates php memcache module

# ref: http://www.php.net/manual/en/memcache.installation.php
#      http://pecl.php.net/package/memcache
URL_PHP_MEMCACHE='http://pecl.php.net/get/memcache-3.0.8.tgz'

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

FILE_PHP_MEMCACHE=`${BASENAME} ${URL_PHP_MEMCACHE}`
DIR_PHP_MEMCACHE=`echo -n ${FILE_PHP_MEMCACHE} | ${SED} 's/\.tgz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILE_PHP_MEMCACHE}" ]; then
    ${WGET} -4 ${URL_PHP_MEMCACHE}

    if [ ! -f "${FILE_PHP_MEMCACHE}" ]; then
        echo "Sorry, can't get ${FILE_PHP_MEMCACHE} for install php memcache module now."
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
if [ -d "${DIR_PHP_MEMCACHE}" ]; then
    ${RM} -rf ${DIR_PHP_MEMCACHE}
fi

# unpack source tarball
${TAR} xzvf ${FILE_PHP_MEMCACHE}

# ----------------------------------------------------------------------

# build and install
cd ${DIR_PHP_MEMCACHE}

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
