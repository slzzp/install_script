#!/bin/sh

AWK='/usr/bin/awk'
CAT='/bin/cat'
CUT='/usr/bin/cut'
GREP='/bin/grep'
HEAD='/usr/bin/head'
HOSTNAME='/bin/hostname'
IFCONFIG='/sbin/ifconfig'
MKDIR='/bin/mkdir'
MV='/bin/mv'
RM='/bin/rm'
SED='/bin/sed'
TR='/usr/bin/tr'
WC='/usr/bin/wc'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

TMPFILE="$0_tmpfile_$$"

cd /tmp

# check apache installed
if [ ! -d '/service/apache2/conf' -o ! -f '/service/apache2/conf/httpd.conf' ]; then
    echo "Sorry, you need to install apache first."
    exit
fi


# mkdir directories
echo "Checking directory: /service/apache2/conf/"

if [ -d '/service/apache2/conf/local_config' ]; then
    echo "  found: local_config"
else
    echo "  mkdir: local_config"

    ${MKDIR} /service/apache2/conf/local_config
fi

if [ -d '/service/apache2/conf/local_sites' ]; then
    echo "  found: local_sites"
else
    echo "  mkdir: local_sites"

    ${MKDIR} /service/apache2/conf/local_sites
fi


# check config files
echo "Checking local_config files: /service/apache2/conf/local_config/"

if [ -f '/service/apache2/conf/local_config/charset' ]; then
    echo "  found: charset (no overwrite)"
else
    if [ -f "${TMPFILE}" ]; then
        ${RM} -rf ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/local_config/charset

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo "  build: charset"

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/charset
fi

if [ -f '/service/apache2/conf/local_config/php' ]; then
    echo "  found: php (no overwrite)"
else
    if [ -f "${TMPFILE}" ]; then
        ${RM} -rf ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/local_config/php

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo "  build: php"

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/php
fi

if [ -f '/service/apache2/conf/local_config/security' ]; then
    echo "  found: security (no overwrite)"
else
    if [ -f "${TMPFILE}" ]; then
        ${RM} -rf ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/local_config/security

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache config file now, or current/working directory is forbidden to write."
        exit
    fi

    echo "  build: security"

    ${MV} ${TMPFILE} /service/apache2/conf/local_config/security
fi


# check site files
echo "Checking local_sites files: /service/apache2/conf/local_sites/"

if [ -f '/service/apache2/conf/local_sites/default' ]; then
    echo "  found: default (no overwrite)"
else
    if [ -f "${TMPFILE}" ]; then
        ${RM} -rf ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/local_sites/default

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache site file now, or current/working directory is forbidden to write."
        exit
    fi


    MYHOSTNAME=`${HOSTNAME}`
    MYHOSTIP=`${IFCONFIG} eth0 | ${GREP} 'inet addr' | ${AWK} '{printf("%s",$2);}' | ${AWK} -F\: '{printf("%s",$2);}' `

    if [ -z "${MYHOSTNAME}" ]; then
        echo "Sorry, can't get hostname. Please check /etc/hostname setting."
        exit
    fi

    if [ -z "${MYHOSTIP}" ]; then
        echo "Sorry, can't get host ip. Please check /etc/network/interfaces setting."
        exit
    fi

    echo "  build: default (with hostname '${MYHOSTNAME}' and host ip '${MYHOSTIP}')"

    ${CAT} ${TMPFILE} \
      | ${SED} "s/MYHOSTNAME/${MYHOSTNAME}/g" \
      | ${SED} "s/MYHOSTIP/${MYHOSTIP}/g" \
      > /service/apache2/conf/local_sites/default
fi


# check httpd.conf
echo "Checking httpd.conf: /service/apache2/conf/httpd.conf"

TMPCOUNT=`${GREP} conf/local_config /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -rf ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/httpd.conf_append_local_config

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache append file now, or current/working directory is forbidden to write."
        exit
    fi

    echo "  append: local_config"

    ${CAT} ${TMPFILE} >> /service/apache2/conf/httpd.conf
else
    echo "  found: local_config"
fi

TMPCOUNT=`${GREP} conf/local_sites /service/apache2/conf/httpd.conf | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    if [ -f "${TMPFILE}" ]; then
        ${RM} -rf ${TMPFILE}
    fi

    ${WGET} -q -O ${TMPFILE} https://raw.github.com/slzzp/install_script/master/debian/apache_conf/httpd.conf_append_local_sites

    if [ ! -f "${TMPFILE}" ]; then
        echo "Sorry, can't get apache append file now, or current/working directory is forbidden to write."
        exit
    fi

    echo "  append: local_sites"

    ${CAT} ${TMPFILE} >> /service/apache2/conf/httpd.conf
else
    echo "  found: local_sites"
fi


# remove temp file
if [ -f "${TMPFILE}" ]; then
    ${RM} -rf ${TMPFILE}
fi
