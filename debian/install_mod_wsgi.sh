#!/bin/sh

# This script generates mod_wsgi of apache2

# ref: https://code.google.com/p/modwsgi/wiki/DownloadTheSoftware?tm=2
#      https://github.com/GrahamDumpleton/mod_wsgi/releases
# URL_MOD_WSGI='https://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz'
URL_MOD_WSGI='https://github.com/GrahamDumpleton/mod_wsgi/archive/4.3.2.tar.gz'

BASENAME='/usr/bin/basename'
CAT='/bin/cat'
CP='/bin/cp'
GREP='/bin/grep'
MAKE='/usr/bin/make'
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

#FILE_MOD_WSGI=`${BASENAME} ${URL_MOD_WSGI}`
FILE_MOD_WSGI='mod_wsgi-4.3.2.tar.gz'
DIR_MOD_WSGI=`echo -n ${FILE_MOD_WSGI} | ${SED} 's/\.tar\.gz//g'`
DIR_PWD=`${PWD}`

cd /tmp

# get source tarball
if [ ! -f "${FILE_MOD_WSGI}" ]; then
    ${WGET} -4 -O ${FILE_MOD_WSGI} ${URL_MOD_WSGI}

    if [ ! -f "${FILE_MOD_WSGI}" ]; then
        echo "Sorry, can't get ${FILE_MOD_WSGI} for install php now."
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
# now python is 2.7
if [ ! -f '/usr/bin/python' -o ! -f '/usr/include/python2.7/Python.h' ]; then
    /usr/bin/apt-get -y install python python-dev
fi

# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIR_MOD_WSGI}" ]; then
    ${RM} -rf ${DIR_MOD_WSGI}
fi

# unpack source tarball
${TAR} xzvf ${FILE_MOD_WSGI}

# ----------------------------------------------------------------------

# build and install
cd ${DIR_MOD_WSGI}

./configure \
  --with-apxs=/service/apache2/bin/apxs \
  --with-python=/usr/bin/python

if [ ! -f 'Makefile' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'src/server/mod_wsgi.la' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE} install

if [ ! -f '/service/apache2/modules/mod_wsgi.so' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

# ----------------------------------------------------------------------

# check setting
TMPCOUNT=`${GREP} 'LoadModule wsgi_module modules/mod_wsgi.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "0" = "${TMPCOUNT}" ]; then
    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_wsgi in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | \
      ${SED} 's/LoadModule alias_module modules\/mod_alias\.so/LoadModule alias_module modules\/mod_alias\.so\nLoadModule wsgi_module modules\/mod_wsgi\.so/g' > \
      /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi

TMPCOUNT=`${GREP} '#LoadModule wsgi_module modules/mod_wsgi.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "0" = "${TMPCOUNT}" ]; then
    echo 'Activated mod_wsgi in /service/apache2/conf/httpd.conf'
else
    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_wsgi in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | \
      ${SED} 's/\#LoadModule wsgi_module modules\/mod_wsgi\.so/LoadModule wsgi_module modules\/mod_wsgi\.so/g' > \
      /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi
