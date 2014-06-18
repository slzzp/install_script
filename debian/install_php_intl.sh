#!/bin/sh

# This script generates php intl module

# ref: http://www.php.net/manual/en/intl.installation.php
#      http://pecl.php.net/package/intl
URLPHPINTL='http://pecl.php.net/get/intl-3.0.0.tgz'

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

FILEPHPINTL=`${BASENAME} ${URLPHPINTL}`
DIRPHPINTL=`echo -n ${FILEPHPINTL} | ${SED} 's/\.tgz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILEPHPINTL}" ]; then
    ${WGET} -4 ${URLPHPINTL}

    if [ ! -f "${FILEPHPINTL}" ]; then
        echo "Sorry, can't get ${FILEPHPINTL} for install php intl module now."
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

if [ ! -f '/usr/bin/icu-config' ]; then
    /usr/bin/apt-get -y install libicu-dev
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIRPHPINTL}" ]; then
    ${RM} -rf ${DIRPHPINTL}
fi

# unpack source tarball
${TAR} xzvf ${FILEPHPINTL}

# ----------------------------------------------------------------------

# build and install
cd ${DIRPHPINTL}

${PHPIZE}

./configure \
  --enable-intl \
  --with-php-config=/service/php/bin/php-config

if [ ! -f 'Makefile' -o ! -f 'config.h' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'modules/intl.la' -o ! -f 'modules/intl.so' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi


EXTDIR=`${FIND} /service/php/lib/php/extensions -type d | ${SORT} | ${TAIL} -n 1`

${CP} modules/intl.so ${EXTDIR}

# copy one more intl.so for install script check
${CP} modules/intl.so /service/php/lib/php/extensions/

# ----------------------------------------------------------------------

# check setting
if [ ! -f '/service/php/lib/php.ini' ]; then
    echo 'Activate intl.so to /service/php/lib/php.ini'

    echo "extension=intl.so\n" > /service/php/lib/php.ini
else
    EXTLINECOUNT=`${GREP} "extension=intl.so" /service/php/lib/php.ini | ${WC} -l | ${TR} -d ' '`
    if [ "0" = "${EXTLINECOUNT}" ]; then
        echo 'Activate intl.so to /service/php/lib/php.ini'

        echo "\nextension=intl.so\n" >> /service/php/lib/php.ini
    else
        echo 'Activated intl.so to /service/php/lib/php.ini'
    fi
fi
