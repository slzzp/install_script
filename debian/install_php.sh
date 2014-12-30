#!/bin/sh

# This script generates php cli + fpm + apache2 module

# ref: http://www.php.net/get/php-5.6.4.tar.gz/from/a/mirror
URL_PHP='http://www.php.net/distributions/php-5.6.4.tar.gz'

BASENAME='/usr/bin/basename'
CAT='/bin/cat'
CHMOD='/bin/chmod'
CP='/bin/cp'
GREP='/bin/grep'
LN='/bin/ln'
MAKE='/usr/bin/make'
MKDIR='/bin/mkdir'
MV='/bin/mv'
PWD='/bin/pwd'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
TOUCH='/bin/touch'
TR='/usr/bin/tr'
WC='/usr/bin/wc'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILE_PHP=`${BASENAME} ${URL_PHP}`
DIR_PHP=`echo -n ${FILE_PHP} | ${SED} 's/\.tar\.gz//g'`
DIR_PWD=`${PWD}`

cd /tmp

# get source tarball
if [ ! -f "${FILE_PHP}" ]; then
    ${WGET} -4 ${URL_PHP}

    if [ ! -f "${FILE_PHP}" ]; then
        echo "Sorry, can't get ${FILE_PHP} for install php now."
        exit
    fi
fi

# check apache2
if [ ! -d '/service/apache2' -o ! -f '/service/apache2/bin/apxs' ]; then
    echo "Sorry, please install apache2 first."
    exit
fi

# ----------------------------------------------------------------------

# pre-install libs
if [ ! -f '/usr/share/doc/libmcrypt-dev/copyright' ]; then
    /usr/bin/apt-get -y install libmcrypt-dev libmcrypt4
fi

if [ ! -f '/usr/share/doc/libxml2-dev/copyright' ]; then
    /usr/bin/apt-get -y install libxml2-dev libxml2
fi

if [ ! -f '/usr/share/doc/libbz2-dev/copyright' ]; then
    /usr/bin/apt-get -y install libbz2-dev
fi

if [ ! -f '/usr/share/doc/libgd2-xpm-dev/copyright' ]; then
    /usr/bin/apt-get -y install libgd2-xpm-dev
    /usr/bin/apt-get -y install libgd2-xpm
fi

if [ ! -f '/usr/bin/re2c' ]; then
    /usr/bin/apt-get -y install re2c
fi

if [ ! -f '/usr/bin/freetype-config' ]; then
    /usr/bin/apt-get -y install libfreetype6-dev
fi

if [ ! -f '/usr/bin/pcre-config' ]; then
    /usr/bin/apt-get -y install libpcre3 libpcre3-dev libpcre++-dev
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIR_PHP}" ]; then
    ${RM} -rf ${DIR_PHP}
fi

# unpack source tarball
${TAR} xzvf ${FILE_PHP}

# ----------------------------------------------------------------------

# build and install
cd ${DIR_PHP}

./configure \
  --prefix=/service/php \
  --enable-ctype \
  --enable-exif \
  --enable-fileinfo \
  --enable-fpm \
  --enable-gd-native-ttf \
  --enable-mbstring \
  --enable-opcache \
  --enable-sockets \
  --enable-zip \
  --with-bz2 \
  --with-freetype-dir \
  --with-gd \
  --with-gettext \
  --with-iconv \
  --with-jpeg-dir \
  --with-mcrypt \
  --with-mhash \
  --with-mysql=/service/mysql \
  --with-mysqli \
  --with-pcre-regex \
  --with-zlib
#  --with-apxs2=/service/apache2/bin/apxs \
#  --with-openssl \
# bug ? OpenSSL 1.0.1e has no openssl/evp.h but php-5.6.4 --with-openssl need it

if [ ! -f 'Makefile' -o ! -f 'main/php_config.h' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'ext/phar/phar/phar.inc' -o ! -f './sapi/cgi/php-cgi' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE} install

if [ ! -f '/service/php/bin/php' -o ! -f '/service/php/sbin/php-fpm' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

# ----------------------------------------------------------------------

# check setting
cd ${DIR_PWD}

if [ ! -f '/service/php/lib/php.ini' ]; then
    ${CP} etc/php.ini /service/php/lib/
fi

if [ ! -f '/service/php/etc/php-fpm.conf' ]; then
    ${CP} etc/php-fpm.conf /service/php/etc/
fi

# ----------------------------------------------------------------------

# set startup script
cd ${DIR_PWD}

if [ ! -f '/etc/init.d/php-fpm' ]; then
    ${CP} etc/php-fpm-init /etc/init.d/php-fpm
fi

${CHMOD} +x /etc/init.d/php-fpm

for RCI in 0 1 6; do
    if [ ! -L "/etc/rc${RCI}.d/K01php-fpm" ]; then
        cd "/etc/rc${RCI}.d"
        ${LN} -s ../init.d/php-fpm "K01php-fpm"
    fi
done

for RCI in 2 3 4 5; do
    if [ ! -L "/etc/rc${RCI}.d/S02php-fpm" ]; then
        cd "/etc/rc${RCI}.d"
        ${LN} -s ../init.d/php-fpm "S02php-fpm"
    fi
done


# ----------------------------------------------------------------------

# check apache setting
if [ ! -f '/service/apache2/conf/local_config/php' ]; then
    ${MKDIR} -p /service/apache2/conf/local_config

    TMPFILE="$0_tmpfile_$$"

    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/local_config/php

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo 'Activate php settings to apache2'

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/php
else
    echo 'Activated php settings to apache2'
fi

# ----------------------------------------------------------------------

# mod_proxy for php-fpm
TMPCOUNT=`${GREP} 'LoadModule proxy_module modules/mod_proxy.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" -o ! -f '/service/apache2/modules/mod_proxy.so' ]; then
    echo "Sorry, mod_proxy is not in apache."
    exit
fi

TMPCOUNT=`${GREP} '#LoadModule proxy_module modules/mod_proxy.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    echo 'Activated mod_proxy in /service/apache2/conf/httpd.conf'
else
    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_proxy in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | \
      ${SED} 's/\#LoadModule proxy_module modules\/mod_proxy\.so/LoadModule proxy_module modules\/mod_proxy\.so/g' > \
      /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi

# ----------------------------------------------------------------------

# mod_proxy_fcgi for php-fpm
TMPCOUNT=`${GREP} 'LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" -o ! -f '/service/apache2/modules/mod_proxy_fcgi.so' ]; then
    echo "Sorry, mod_proxy_fcgi is not in apache."
    exit
fi

TMPCOUNT=`${GREP} '#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    echo 'Activated mod_proxy_fcgi in /service/apache2/conf/httpd.conf'
else
    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_proxy_fcgi in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | \
      ${SED} 's/\#LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi\.so/LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi\.so/g' > \
      /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi

# ----------------------------------------------------------------------

# mod_rewrite for Zend Framework / PixFramework
TMPCOUNT=`${GREP} 'LoadModule rewrite_module modules/mod_rewrite.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" -o ! -f '/service/apache2/modules/mod_rewrite.so' ]; then
    if [ ! -f '/service/apache2/modules/mod_rewrite.so' ]; then
        echo "Sorry, mod_rewrite is not in apache."
        exit
    fi

    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_rewrite in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | \
      ${SED} 's/LoadModule alias_module modules\/mod_alias\.so/LoadModule alias_module modules\/mod_alias\.so\nLoadModule rewrite_module modules\/mod_rewrite\.so/g' > \
      /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi

TMPCOUNT=`${GREP} '#LoadModule rewrite_module modules/mod_rewrite.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    echo 'Activated mod_rewrite in /service/apache2/conf/httpd.conf'
else
    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_rewrite in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | \
      ${SED} 's/\#LoadModule rewrite_module modules\/mod_rewrite\.so/LoadModule rewrite_module modules\/mod_rewrite\.so/g' > \
      /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi
