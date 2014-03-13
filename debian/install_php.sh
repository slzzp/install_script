#!/bin/sh

# This script generates php cli + fpm + apache2 module

# ref: http://www.php.net/get/php-5.5.10.tar.gz/from/a/mirror
URLPHP='http://www.php.net/distributions/php-5.5.10.tar.gz'

BASENAME='/usr/bin/basename'
MAKE='/usr/bin/make'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILEPHP=`${BASENAME} ${URLPHP}`
DIRPHP=`echo -n ${FILEPHP} | ${SED} 's/\.tar\.gz//g'`

cd /tmp

# get source tarball
if [ ! -f "${FILEPHP}" ]; then
    ${WGET} -4 ${URLPHP}

    if [ ! -f "${FILEPHP}" ]; then
        echo "Sorry, can't get ${FILEPHP} for install php now."
        exit
    fi
fi

# remove old directory
if [ -d "${DIRPHP}" ]; then
    ${RM} -rf ${DIRPHP}
fi

# unpack source tarball
${TAR} xzvf ${FILEPHP}


# build and install
cd ${DIRPHP}

./configure --prefix=/service/php \
  --enable-ctype \
  --enable-fileinfo \
  --enable-fpm \
  --enable-mbstring \
  --enable-sockets \
  --with-apxs2=/service/apache2/bin/apxs \
  --with-gd \
  --with-gettext \
  --with-mcrypt \
  --with-mhash \
  --with-mysql \
  --with-mysqli \
  --with-pcre-regex \
  --with-zlib
#  --with-openssl \
# bug ? OpenSSL 1.0.1e has no openssl/evp.h but php-5.5.10 --with-openssl need it

${MAKE}
${MAKE} install
