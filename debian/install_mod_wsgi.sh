#!/bin/sh

# This script generates mod_wsgi of apache2

# ref: https://code.google.com/p/modwsgi/wiki/DownloadTheSoftware?tm=2
#      https://github.com/GrahamDumpleton/mod_wsgi/releases
# URLPHP='https://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz'
URLPHP='https://github.com/GrahamDumpleton/mod_wsgi/archive/4.3.2.tar.gz'

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

#FILEPHP=`${BASENAME} ${URLPHP}`
FILEPHP='mod_wsgi-4.3.2.tar.gz'
DIRPHP=`echo -n ${FILEPHP} | ${SED} 's/\.tar\.gz//g'`
DIRPWD=`${PWD}`

cd /tmp

# get source tarball
if [ ! -f "${FILEPHP}" ]; then
    ${WGET} -4 -O ${FILEPHP} ${URLPHP}

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
# now python is 2.7
if [ ! -f '/usr/bin/python' -o ! -f '/usr/include/python2.7/Python.h' ]; then
    /usr/bin/apt-get -y install python python-dev
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
