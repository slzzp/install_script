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

# install need wget
if [ ! -f '/usr/bin/wget' ]; then
    /usr/bin/apt-get -y install wget
fi

if [ ! -f '/usr/sbin/iftop' ]; then
    /usr/bin/apt-get -y install iftop
fi

# I like to use s3cmd for remote backup
if [ ! -f '/usr/bin/s3cmd' ]; then
    /usr/bin/apt-get -y install s3cmd python-magic
fi

# or aws-cli
if [ ! -f '/usr/bin/pip' -o ! -f '/usr/local/bin/aws' ]; then
    /usr/bin/apt-get -y install python-pip
    /usr/bin/pip install awscli
fi

if [ ! -f '/usr/bin/pcre-config' ]; then
    /usr/bin/apt-get -y install libpcre3 libpcre3-dev libpcre++-dev
fi

if [ ! -f '/usr/bin/pkg-config' ]; then
    /usr/bin/apt-get -y install pkg-config
fi

if [ ! -f '/usr/share/doc/libssl-dev/copyright' ]; then
    /usr/bin/apt-get -y install libssl-dev libssl-doc
fi

if [ ! -f '/usr/share/doc/zlib1g/copyright' ]; then
    /usr/bin/apt-get -y install zlib1g zlib1g-dev
fi


# developer need gettext
if [ ! -f '/usr/bin/gettext' ]; then
    /usr/bin/apt-get -y install gettext
fi

# full locale data
if [ ! -f '/usr/bin/locale' -o ! -f '/usr/share/doc/locales-all/copyright' ]; then
    /usr/bin/apt-get -y install locales locales-all
fi


# developer need git
if [ ! -f '/usr/bin/git' ]; then
    /usr/bin/apt-get -y install git
fi

# developer need tig
if [ ! -f '/usr/bin/tig' ]; then
    /usr/bin/apt-get -y install tig
fi


# developer need autoconf
if [ ! -f '/usr/bin/autoconf' ]; then
    /usr/bin/apt-get -y install autoconf
fi

# developer need make
if [ ! -f '/usr/bin/make' ]; then
    /usr/bin/apt-get -y install make
fi

# developer need libtool
if [ ! -f '/usr/bin/libtool' ]; then
    /usr/bin/apt-get -y install libtool
fi

# developer need gcc
if [ ! -f '/usr/bin/gcc' ]; then
    /usr/bin/apt-get -y install gcc
fi


# developer need yui-compressor
if [ ! -f '/usr/bin/yui-compressor' ]; then
    /usr/bin/apt-get -y install yui-compressor
fi

# ----------------------------------------------------------------------

# install apr from source
CHECKFILE='/service/apr/bin/apr-1-config'
if [ ! -f "${CHECKFILE}" ]; then
    if [ ! -f 'install_apr.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/install_apr.sh

        if [ ! -f 'install_apr.sh' ]; then
            echo "Sorry, can't get script for installing apr now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh install_apr.sh
fi

if [ ! -f "${CHECKFILE}" ]; then
    echo "Sorry, error occurs during building apr. Please check error messages and fix them manually, then re-run install script."
    exit
fi

# install apr-util from source
CHECKFILE='/service/apr-util/bin/apu-1-config'
if [ ! -f "${CHECKFILE}" ]; then
    if [ ! -f 'install_apr-util.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/install_apr-util.sh

        if [ ! -f 'install_apr-util.sh' ]; then
            echo "Sorry, can't get script for installing apr-util now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh install_apr-util.sh
fi

if [ ! -f "${CHECKFILE}" ]; then
    echo "Sorry, error occurs during building apr-util. Please check error messages and fix them manually, then re-run install script."
    exit
fi

# install apache from source
CHECKFILE='/service/apache2/bin/httpd'
if [ ! -f "${CHECKFILE}" ]; then
    if [ ! -f 'install_apache.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/install_apache.sh

        if [ ! -f 'install_apache.sh' ]; then
            echo "Sorry, can't get script for installing apache now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh install_apache.sh
fi

if [ ! -f "${CHECKFILE}" ]; then
    echo "Sorry, error occurs during building apache. Please check error messages and fix them manually, then re-run install script."
    exit
fi

# install php from source
CHECKFILE='/service/php/bin/php'
if [ ! -f "${CHECKFILE}" ]; then
    if [ ! -f 'install_php.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/install_php.sh

        if [ ! -f 'install_php.sh' ]; then
            echo "Sorry, can't get script for installing php now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh install_php.sh
fi

if [ ! -f "${CHECKFILE}" ]; then
    echo "Sorry, error occurs during building php. Please check error messages and fix them manually, then re-run install script."
    exit
fi

# ----------------------------------------------------------------------

# install apache mod_wsgi from source
CHECKFILE='/service/apache2/modules/mod_wsgi.so'
if [ ! -f "${CHECKFILE}" ]; then
    if [ ! -f 'install_mod_wsgi.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/install_mod_wsgi.sh

        if [ ! -f 'install_mod_wsgi.sh' ]; then
            echo "Sorry, can't get script for installing apache mod_wsgi now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh install_mod_wsgi.sh
fi

if [ ! -f "${CHECKFILE}" ]; then
    echo "Sorry, error occurs during building apache mod_wsgi. Please check error messages and fix them manually, then re-run install script."
    exit
fi

# install php memcache module from source
CHECKFILE='/service/php/lib/php/extensions/memcache.so'
if [ ! -f "${CHECKFILE}" ]; then
    if [ ! -f 'install_php_memcache.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/install_php_memcache.sh

        if [ ! -f 'install_php_memcache.sh' ]; then
            echo "Sorry, can't get script for installing php memcache module now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh install_php_memcache.sh
fi

if [ ! -f "${CHECKFILE}" ]; then
    echo "Sorry, error occurs during building php memcache module. Please check error messages and fix them manually, then re-run install script."
    exit
fi

# ----------------------------------------------------------------------

if [ -f '/service/apache2/conf/httpd.conf' ]; then
    if [ ! -f 'fix_apache_conf.sh' ]; then
        /usr/bin/wget https://raw.githubusercontent.com/slzzp/install_script/master/debian/fix_apache_conf.sh

        if [ ! -f 'fix_apache_conf.sh' ]; then
            echo "Sorry, can't get script for fixing apache conf now, or current/working directory is forbidden to write."
            exit
        fi
    fi

    /bin/sh fix_apache_conf.sh
fi

