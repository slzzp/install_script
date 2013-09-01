#!/bin/sh

# install need apt-get
if [ ! -f '/usr/bin/apt-get' ]; then
    echo "Sorry, you need to install apt-get by yourself."
    exit
fi

# check root
if [ ! 'root' = `/usr/bin/whoami` ]; then
    echo "Sorry, you must be root to run install script."
    exit
fi

# ----------------------------------------------------------------------

# update apt list/packages first
/usr/bin/apt-get -y update
/usr/bin/apt-get -y upgrade

# ----------------------------------------------------------------------

# install need wget
if [ ! -f '/usr/bin/wget' ]; then
    /usr/bin/apt-get -y install wget
fi

# install need git
if [ ! -f '/usr/bin/git' ]; then
    /usr/bin/apt-get -y install git
fi

# tig for git
if [ ! -f '/usr/bin/tig' ]; then
    /usr/bin/apt-get -y install tig
fi

# developer need gcc
if [ ! -f '/usr/bin/gcc' ]; then
    /usr/bin/apt-get -y install gcc
fi

# developer need libtool
if [ ! -f '/usr/bin/libtool' ]; then
    /usr/bin/apt-get -y install libtool
fi

# developer need libxml2
if [ ! -f '/usr/lib/x86_64-linux-gnu/libxml2.so.2' -a ! -f '/usr/lib/libxml2.so.2' ]; then
    /usr/bin/apt-get -y install libxml2 libxml2-dev
fi

# developer need gd2
if [ ! -f '/usr/lib/x86_64-linux-gnu/libgd.so.2' -a ! -f '/usr/lib/libgd.so.2' ]; then
    /usr/bin/apt-get -y install libgd2-xpm libgd2-xpm-dev
fi

# developer need pcre
if [ ! -f '/usr/bin/pcre-config' ]; then
    /usr/bin/apt-get -y install libpcre3 libpcre3-dev libpcre++-dev
fi

# full locale data
if [ ! -f '/usr/bin/locale' -o ! -f '/usr/share/doc/locales-all/copyright' ]; then
    /usr/bin/apt-get -y install locales locales-all
fi

# monitor apache activities
if [ ! -f '/usr/sbin/apachetop' ]; then
    /usr/bin/apt-get -y install apachetop
fi

# I like to use tcsh for shell
if [ ! -f '/usr/bin/tcsh' ]; then
    /usr/bin/apt-get -y install tcsh
fi

# I like to use screen for terminal control
if [ ! -f '/usr/bin/screen' ]; then
    /usr/bin/apt-get -y install screen
fi

# I like to use joe for editor
if [ ! -f '/usr/bin/joe' ]; then
    /usr/bin/apt-get -y install joe
fi

# I like to use sudo as root
if [ ! -f '/usr/bin/sudo' ]; then
    /usr/bin/apt-get -y install sudo
fi

# I like to use s3cmd for remote backup
if [ ! -f '/usr/bin/s3cmd' ]; then
    /usr/bin/apt-get -y install s3cmd
fi
