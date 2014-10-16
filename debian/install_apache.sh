#!/bin/sh

# ref: http://httpd.apache.org/download.cgi?Preferred=http%3A%2F%2Fftp.twaren.net%2FUnix%2FWeb%2Fapache%2F
URLAPACHE='http://ftp.twaren.net/Unix/Web/apache//httpd/httpd-2.4.10.tar.gz'

AWK='/usr/bin/awk'
BASENAME='/usr/bin/basename'
CAT='/bin/cat'
CHMOD='/bin/chmod'
CP='/bin/cp'
CUT='/usr/bin/cut'
GREP='/bin/grep'
HEAD='/usr/bin/head'
HOSTNAME='/bin/hostname'
IFCONFIG='/sbin/ifconfig'
LN='/bin/ln'
MAKE='/usr/bin/make'
MKDIR='/bin/mkdir'
MV='/bin/mv'
PWD='/bin/pwd'
OPENSSL='/usr/bin/openssl'
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
DIRPWD=`${PWD}`

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
if [ ! -f "${OPENSSL}" ]; then
    /usr/bin/apt-get -y install openssl
fi

if [ ! -f '/usr/bin/pcre-config' ]; then
    /usr/bin/apt-get -y install libpcre3 libpcre3-dev libpcre++-dev
fi

# ----------------------------------------------------------------------

if [ -f '/blah' ]; then

# remove old directory
if [ -d "${DIRAPACHE}" ]; then
    ${RM} -rf ${DIRAPACHE}
fi

# unpack source tarball
${TAR} xzvf ${FILEAPACHE}

# ----------------------------------------------------------------------

# build
cd ${DIRAPACHE}

./configure \
  --prefix=/service/apache2 \
  --enable-rewrite \
  --enable-ssl \
  --enable-so \
  --with-apr=/service/apr \
  --with-apr-util=/service/apr-util

if [ ! -f 'Makefile' -o ! -f 'test/Makefile' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'modules/mappers/mod_alias.la' -o ! -f 'modules/mappers/mod_alias.lo' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE} install

if [ ! -f '/service/apache2/bin/httpd' -o ! -f '/service/apache2/modules/mod_alias.so' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

fi

# ----------------------------------------------------------------------

# set startup script
cd ${DIRPWD}

if [ ! -f '/etc/init.d/apache2' ]; then
    ${CP} etc/apache2-init /etc/init.d/apache2
fi

${CHMOD} +x /etc/init.d/apache2

for RCI in 0 1 6; do
    if [ ! -L "/etc/rc${RCI}.d/K01apache2" ]; then
        cd "/etc/rc${RCI}.d"
        ${LN} -s ../init.d/apache2 "K01apache2"
    fi
done

for RCI in 2 3 4 5; do
    if [ ! -L "/etc/rc${RCI}.d/S02apache2" ]; then
        cd "/etc/rc${RCI}.d"
        ${LN} -s ../init.d/apache2 "S02apache2"
    fi
done

# ----------------------------------------------------------------------

TMPFILE="$0_tmpfile_$$"

if [ ! -d '/service/apache2/conf/local_config' ]; then
    echo 'Build /service/apache2/conf/local_config'

    ${MKDIR} /service/apache2/conf/local_config
else
    echo 'Found /service/apache2/conf/local_config'
fi

TMPCOUNT=`${GREP} conf/local_config /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/httpd.conf_append_local_config

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache append file now, or current/working directory is forbidden to write."
        exit
    fi

    echo 'Activate conf/local_config to /service/apache2/conf/httpd.conf'

    ${CAT} ${TMPFILE} >> /service/apache2/conf/httpd.conf
else
    echo 'Activated conf/local_config to /service/apache2/conf/httpd.conf'
fi

# ----------------------------------------------------------------------

if [ ! -d '/service/apache2/conf/local_sites' ]; then
    echo 'Build /service/apache2/conf/local_sites'

    ${MKDIR} /service/apache2/conf/local_sites
else
    echo 'Found /service/apache2/conf/local_sites'
fi

TMPCOUNT=`${GREP} conf/local_sites /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/httpd.conf_append_local_sites

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache append file now, or current/working directory is forbidden to write."
        exit
    fi

    echo 'Activate conf/local_sites to /service/apache2/conf/httpd.conf'

    ${CAT} ${TMPFILE} >> /service/apache2/conf/httpd.conf
else
    echo 'Activated conf/local_sites to /service/apache2/conf/httpd.conf'
fi

# ----------------------------------------------------------------------

if [ ! -f '/service/apache2/conf/local_config/charset' ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/local_config/charset

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo 'Build charset to /service/apache2/conf/local_config'

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/charset
else
    echo 'Found charset to /service/apache2/conf/local_config'
fi

if [ ! -f '/service/apache2/conf/local_config/security' ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/local_config/security

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo 'Build security to /service/apache2/conf/local_config'

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/security
else
    echo 'Found security to /service/apache2/conf/local_config'
fi

if [ -f '/service/apache2/modules/mod_ssl.so' -a ! -f '/service/apache2/conf/local_config/ssl' ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/local_config/ssl

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo 'Build ssl to /service/apache2/conf/local_config'

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/ssl
else
    echo 'Found ssl to /service/apache2/conf/local_config'
fi

# ----------------------------------------------------------------------

if [ ! -f '/service/apache2/conf/local_sites/default' ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/local_sites/default

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache site file now, or current/working directory is forbidden to write."
        exit
    fi


    MYHOSTNAME=`${HOSTNAME}`
    # usually use eth0
    MYHOSTIP=`${IFCONFIG} eth0 | ${GREP} 'inet addr' | ${AWK} '{printf("%s",$2);}' | ${AWK} -F\: '{printf("%s",$2);}' `

    if [ -z "${MYHOSTNAME}" ]; then
        echo "Sorry, can't get hostname. Please check /etc/hostname setting."
        exit
    fi

    if [ -z "${MYHOSTIP}" ]; then
        echo "Sorry, can't get host ip. Please check /etc/network/interfaces setting, or fix this scirpt if you are not using eth0."
        exit
    fi

    echo "Build default to /service/apache2/conf/local_sites using hostname '${MYHOSTNAME}' and host ip '${MYHOSTIP}'"

    ${CAT} ${TMPFILE} | \
      ${SED} "s/MYHOSTNAME/${MYHOSTNAME}/g" | \
      ${SED} "s/MYHOSTIP/${MYHOSTIP}/g" > \
      /service/apache2/conf/local_sites/default

    ${MKDIR} -p /service/apache2/logs/default
else
    echo 'Found default to /service/apache2/conf/local_sites'
fi

if [ -f '/service/apache2/modules/mod_ssl.so' -a ! -f '/service/apache2/conf/local_sites/default-ssl' ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -f ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.githubusercontent.com/slzzp/install_script/master/debian/apache_conf/local_sites/default-ssl

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache site file now, or current/working directory is forbidden to write."
        exit
    fi


    MYHOSTNAME=`${HOSTNAME}`
    # usually use eth0
    MYHOSTIP=`${IFCONFIG} eth0 | ${GREP} 'inet addr' | ${AWK} '{printf("%s",$2);}' | ${AWK} -F\: '{printf("%s",$2);}' `

    if [ -z "${MYHOSTNAME}" ]; then
        echo "Sorry, can't get hostname. Please check /etc/hostname setting."
        exit
    fi

    if [ -z "${MYHOSTIP}" ]; then
        echo "Sorry, can't get host ip. Please check /etc/network/interfaces setting, or fix this scirpt if you are not using eth0."
        exit
    fi

    echo "Build default-ssl to /service/apache2/conf/local_sites using hostname '${MYHOSTNAME}' and host ip '${MYHOSTIP}'"

    ${CAT} ${TMPFILE} | \
      ${SED} "s/MYHOSTNAME/${MYHOSTNAME}/g" | \
      ${SED} "s/MYHOSTIP/${MYHOSTIP}/g" > \
      /service/apache2/conf/local_sites/default-ssl

    ${MKDIR} -p /service/apache2/logs/default
else
    echo 'Found default-ssl to /service/apache2/conf/local_sites'
fi

# ----------------------------------------------------------------------

# remove temp file
if [ -f "${TMPFILE}" ]; then
    ${RM} -f ${TMPFILE}
fi

# ----------------------------------------------------------------------

# post-install apache tools
if [ ! -f '/usr/sbin/apachetop' ]; then
    /usr/bin/apt-get -y install apachetop
fi

# ----------------------------------------------------------------------

# SSL
if [ -f '/service/apache2/modules/mod_ssl.so' ]; then
    TMPCOUNT=`${GREP} 'LoadModule ssl_module modules/mod_ssl.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
    if [ "0" = "${TMPCOUNT}" ]; then
        if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
            ${RM} -f /service/apache2/conf/httpd.conf.new
        fi

        echo 'Activate mod_ssl in /service/apache2/conf/httpd.conf'

        ${CAT} /service/apache2/conf/httpd.conf | \
          ${SED} 's/LoadModule alias_module modules\/mod_alias\.so/LoadModule alias_module modules\/mod_alias\.so\nLoadModule ssl_module modules\/mod_ssl\.so/g' > \
          /service/apache2/conf/httpd.conf.new

        ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
    fi

    TMPCOUNT=`${GREP} '#LoadModule ssl_module modules/mod_ssl.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
    if [ "0" = "${TMPCOUNT}" ]; then
        echo 'Activated mod_ssl in /service/apache2/conf/httpd.conf'
    else
        if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
            ${RM} -f /service/apache2/conf/httpd.conf.new
        fi

        echo 'Activate mod_ssl in /service/apache2/conf/httpd.conf'

        ${CAT} /service/apache2/conf/httpd.conf | \
          ${SED} 's/\#LoadModule ssl_module modules\/mod_ssl\.so/LoadModule ssl_module modules\/mod_ssl\.so/g' > \
          /service/apache2/conf/httpd.conf.new

        ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
    fi


    TMPCOUNT=`${GREP} 'LoadModule socache_shmcb_module modules/mod_socache_shmcb.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
    if [ "0" = "${TMPCOUNT}" ]; then
        if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
            ${RM} -f /service/apache2/conf/httpd.conf.new
        fi

        echo 'Activate mod_socache_shmcb in /service/apache2/conf/httpd.conf'

        ${CAT} /service/apache2/conf/httpd.conf | \
          ${SED} 's/LoadModule alias_module modules\/mod_alias\.so/LoadModule alias_module modules\/mod_alias\.so\nLoadModule socache_shmcb_module modules\/mod_socache_shmcb\.so/g' > \
          /service/apache2/conf/httpd.conf.new

        ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
    fi

    TMPCOUNT=`${GREP} '#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so' /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
    if [ "0" = "${TMPCOUNT}" ]; then
        echo 'Activated mod_socache_shmcb in /service/apache2/conf/httpd.conf'
    else
        if [ -f '/service/apache2/conf/httpd.conf.new' ]; then
            ${RM} -f /service/apache2/conf/httpd.conf.new
        fi

        echo 'Activate mod_socache_shmcb in /service/apache2/conf/httpd.conf'

        ${CAT} /service/apache2/conf/httpd.conf | \
          ${SED} 's/\#LoadModule socache_shmcb_module modules\/mod_socache_shmcb\.so/LoadModule socache_shmcb_module modules\/mod_socache_shmcb\.so/g' > \
          /service/apache2/conf/httpd.conf.new

        ${MV} /service/apache2/conf/httpd.conf.new /service/apache2/conf/httpd.conf
    fi


    if [ ! -f '/service/apache2/conf/server.key' -o ! -f '/service/apache2/conf/server.crt' ]; then
        echo "\n\n========== MAKE DEFAULT HOST DOMAIN NAME CERT ==========\n"

        ${OPENSSL} req -new -x509 -days 999 -nodes -out /service/apache2/conf/server.crt -keyout /service/apache2/conf/server.key
    fi

    if [ ! -f '/service/apache2/conf/server_ip.key' -o ! -f '/service/apache2/conf/server_ip.crt' ]; then
        echo "\n\n========= MAKE DEFAULT HOST IP CERT ==========\n"

        ${OPENSSL} req -new -x509 -days 999 -nodes -out /service/apache2/conf/server_ip.crt -keyout /service/apache2/conf/server_ip.key
    fi
fi
