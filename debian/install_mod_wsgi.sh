#!/bin/sh

# This script generates mod_wsgi of apache2

# ref: https://code.google.com/p/modwsgi/wiki/DownloadTheSoftware?tm=2
URLPHP='https://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz'

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

${MAKE}
${MAKE} install

# ----------------------------------------------------------------------

# check setting
CHECKCOUNT=`${GREP} 'LoadModule wsgi_module modules/mod_wsgi.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "0" = "${CHECKCOUNT}" ]; then
    if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
        ${RM} -f /service/apache2/conf/httpd.conf.new
    fi

    echo 'Activate mod_wsgi in /service/apache2/conf/httpd.conf'

    ${CAT} /service/apache2/conf/httpd.conf | ${SED} 's/LoadModule rewrite_module modules\/mod_rewrite\.so/LoadModule rewrite_module modules\/mod_rewrite\.so\nLoadModule wsgi_module modules\/mod_wsgi\.so/g' > /service/apache2/conf/httpd.conf.new

    ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
fi
