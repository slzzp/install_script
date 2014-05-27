#!/bin/sh

# This script generates php cli + fpm + apache2 module

# ref: http://www.php.net/get/php-5.5.12.tar.gz/from/a/mirror
URLPHP='http://www.php.net/distributions/php-5.5.12.tar.gz'

BASENAME='/usr/bin/basename'
CAT='/bin/cat'
CP='/bin/cp'
GREP='/bin/grep'
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

FILEPHP=`${BASENAME} ${URLPHP}`
DIRPHP=`echo -n ${FILEPHP} | ${SED} 's/\.tar\.gz//g'`
DIRPWD=`${PWD}`

cd /tmp

# get source tarball
if [ ! -f "${FILEPHP}" ]; then
    ${WGET} -4 ${URLPHP}

    if [ ! -f "${FILEPHP}" ]; then
        echo "Sorry, can't get ${FILEPHP} for install php now."
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
    /usr/bin/apt-get -y install libgd2-xpm-dev libgd2-xpm
fi

if [ ! -f '/usr/bin/pcre-config' ]; then
    /usr/bin/apt-get -y install libpcre3 libpcre3-dev libpcre++-dev
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIRPHP}" ]; then
    ${RM} -rf ${DIRPHP}
fi

# unpack source tarball
${TAR} xzvf ${FILEPHP}

# ----------------------------------------------------------------------

# build and install
cd ${DIRPHP}

./configure --prefix=/service/php \
  --enable-ctype \
  --enable-exif \
  --enable-fileinfo \
  --enable-fpm \
  --enable-gd-native-ttf \
  --enable-gd-jis-conv \
  --enable-mbstring \
  --enable-opcache \
  --enable-sockets \
  --enable-zip \
  --with-bz2 \
  --with-gd \
  --with-gettext \
  --with-iconv \
  --with-mcrypt \
  --with-mhash \
  --with-mysql \
  --with-mysqli \
  --with-pcre-regex \
  --with-zlib
#  --with-apxs2=/service/apache2/bin/apxs \
#  --with-openssl \
# bug ? OpenSSL 1.0.1e has no openssl/evp.h but php-5.5.12 --with-openssl need it

${MAKE}
${MAKE} install

# ----------------------------------------------------------------------

# check setting
cd ${DIRPWD}

if [ ! -f '/service/php/lib/php.ini' ]; then
    ${CP} etc/php.ini /service/php/lib/
fi

if [ ! -f '/service/php/etc/php-fpm.conf' ]; then
    ${CP} etc/php-fpm.conf /service/php/etc/
fi

# ----------------------------------------------------------------------

CHECKCOUNT=`${GREP} /service/php/sbin/php-fpm /etc/rc.local | ${WC} -l | ${TR} -d ' '`
if [ "0" = "${CHECKCOUNT}" ]; then
    echo 'Activate php-fpm in /etc/rc.local'

    ${TOUCH} /etc/rc.local
    echo '/service/php/sbin/php-fpm &' >> /etc/rc.local
fi

# ----------------------------------------------------------------------

# check apache setting
if [ ! -f '/service/apache2/conf/local_config/php' ]; then
    echo 'Activate php settings to apache2'

    ${MKDIR} -p /service/apache2/conf/local_config

    TMPFILE="$0_tmpfile_$$"

    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/local_config/php

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/php
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
