#!/bin/sh

# ref: http://dev.mysql.com/downloads/mysql/
URLMYSQL='http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.19.tar.gz'

INSTALL_DIR='/service/mysql'
MYSQL_DATA_DIR='/var/lib/mysql'

BASENAME='/usr/bin/basename'
CHMOD='/bin/chmod'
CHOWN='/bin/chown'
CMAKE='/usr/bin/cmake'
CP='/bin/cp'
GREP='/bin/grep'
GROUPADD='/usr/sbin/groupadd'
LN='/bin/ln'
MAKE='/usr/bin/make'
MKDIR='/bin/mkdir'
PWD='/bin/pwd'
RM='/bin/rm'
SED='/bin/sed'
TAR='/bin/tar'
TR='/usr/bin/tr'
USERADD='/usr/sbin/useradd'
WC='/usr/bin/wc'
WGET='/usr/bin/wget'

# ----------------------------------------------------------------------

FILEMYSQL=`${BASENAME} ${URLMYSQL}`
DIRMYSQL=`echo -n ${FILEMYSQL} | ${SED} 's/\.tar\.gz//g'`
DIRPWD=`${PWD}`

cd /tmp

# get source tarball
if [ ! -f "${FILEMYSQL}" ]; then
    ${WGET} -4 ${URLMYSQL}

    if [ ! -f "${FILEMYSQL}" ]; then
        echo "Sorry, can't get ${FILEMYSQL} for install mysql now."
        exit
    fi
fi

# ----------------------------------------------------------------------

# pre-install libs
if [ ! -f "${CMAKE}" ]; then
    /usr/bin/apt-get -y install cmake
fi

if [ ! -f '/usr/bin/bison' ]; then
    /usr/bin/apt-get -y install bison
fi

if [ ! -f '/usr/share/doc/libncurses5-dev/copyright' ]; then
    /usr/bin/apt-get -y install libncurses5 libncurses5-dev
fi


# ----------------------------------------------------------------------

# remove old directory
if [ -d "${DIRMYSQL}" ]; then
    ${RM} -rf ${DIRMYSQL}
fi

# unpack source tarball
${TAR} xzvf ${FILEMYSQL}

# ----------------------------------------------------------------------

# build and install
cd ${DIRMYSQL}

${CMAKE} \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
  -DMYSQL_DATADIR=${MYSQL_DATA_DIR} \
  -DWITH_ZLIB=system \
  -DDEFAULT_CHARSET=utf8mb4 \
  -DDEFAULT_COLLATION=utf8mb4_general_ci \
  .

if [ ! -f 'Makefile' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

${MAKE}

if [ ! -f 'sql/mysqld' -o ! -f 'mysql-test/lib/My/SafeProcess/my_safe_process' ]; then
    echo 'Sorry, error occurs before.'
    exit
fi

cd ${DIRMYSQL}

${MAKE} install

if [ ! -f "${INSTALL_DIR}/bin/mysql" -o ! -f "${INSTALL_DIR}/bin/mysqld" ]; then
    echo 'Sorry, error occurs before.'
    exit
fi


# ----------------------------------------------------------------------

# remove files
if [ -f "${INSTALL_DIR}/bin/mysql_client_test_embedded" ]; then
    ${RM} ${INSTALL_DIR}/bin/mysql_client_test_embedded
fi

if [ -f "${INSTALL_DIR}/bin/mysql_embedded" ]; then
    ${RM} ${INSTALL_DIR}/bin/mysql_embedded
fi

if [ -f "${INSTALL_DIR}/bin/mysqltest_embedded" ]; then
    ${RM} ${INSTALL_DIR}/bin/mysqltest_embedded
fi

if [ -d "${INSTALL_DIR}/mysql-test" ]; then
    ${RM} -rf ${INSTALL_DIR}/mysql-test
fi

if [ -d "${INSTALL_DIR}/data" ]; then
    ${RM} -rf ${INSTALL_DIR}/data
fi

# ----------------------------------------------------------------------

# add mysql user and group

TMPCOUNT=`${GREP} '^mysql:' /etc/group | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    ${GROUPADD} -f -g 3306 mysql
fi

TMPCOUNT=`${GREP} '^mysql:' /etc/passwd | ${WC} -l | ${TR} -d ' '`
if [ "${TMPCOUNT}" = "0" ]; then
    ${USERADD} -r -u 3306 -g mysql mysql
fi

# ----------------------------------------------------------------------

# set data dir
if [ ! -d "${MYSQL_DATA_DIR}" ]; then
    ${MKDIR} -p ${MYSQL_DATA_DIR}
fi

${CHOWN} -R mysql:mysql ${MYSQL_DATA_DIR}
${CHMOD} 700 ${MYSQL_DATA_DIR}

# ----------------------------------------------------------------------

# set default mysql database/table
if [ ! -d "${MYSQL_DATA_DIR}/mysql" -o ! -f "${MYSQL_DATA_DIR}/mysql/user.MYD" ]; then
    ${INSTALL_DIR}/scripts/mysql_install_db \
      --basedir=${INSTALL_DIR} \
      --datadir=${MYSQL_DATA_DIR} \
      --skip-name-resolve \
      --no-defaults \
      --user=mysql
fi

# ----------------------------------------------------------------------

# set default cnf
cd ${DIRPWD}

if [ ! -d "${INSTALL_DIR}/etc" ]; then
    ${MKDIR} -p ${INSTALL_DIR}/etc
fi

if [ ! -f "${INSTALL_DIR}/etc/admin.cnf" ]; then
    ${CP} etc/mysql-admin.cnf "${INSTALL_DIR}/etc/admin.cnf"
fi

if [ ! -f "${INSTALL_DIR}/etc/my.cnf" ]; then
    ${CP} etc/mysql-my.cnf "${INSTALL_DIR}/etc/my.cnf"
fi

if [ ! -f "/etc/my.cnf" ]; then
    ${LN} -s "${INSTALL_DIR}/etc/my.cnf" /etc/my.cnf
fi

if [ -f "${INSTALL_DIR}/my.cnf" ]; then
    ${RM} "${INSTALL_DIR}/my.cnf"
fi

${LN} -s "${INSTALL_DIR}/etc/my.cnf" "${INSTALL_DIR}/my.cnf"

echo "\nIf you change mysql root password, update root password in ${INSTALL_DIR}/etc/admin.cnf\n"

# ----------------------------------------------------------------------

# set startup script
cd ${DIRPWD}

if [ ! -f '/etc/init.d/mysql' ]; then
    ${CP} etc/mysql-init /etc/init.d/mysql
    ${CHMOD} +x /etc/init.d/mysql
fi

${CHMOD} 755 /etc/init.d/mysql

if [ ! -f '/etc/rc0.d/K01mysql' ]; then
    cd /etc/rc0.d
    ${LN} -s ../init.d/mysql K01mysql 
fi

if [ ! -f '/etc/rc1.d/K01mysql' ]; then
    cd /etc/rc1.d
    ${LN} -s ../init.d/mysql K01mysql 
fi

if [ ! -f '/etc/rc2.d/S02mysql' ]; then
    cd /etc/rc2.d
    ${LN} -s ../init.d/mysql S02mysql 
fi

if [ ! -f '/etc/rc3.d/S02mysql' ]; then
    cd /etc/rc3.d
    ${LN} -s ../init.d/mysql S02mysql 
fi

if [ ! -f '/etc/rc4.d/S02mysql' ]; then
    cd /etc/rc4.d
    ${LN} -s ../init.d/mysql S02mysql 
fi

if [ ! -f '/etc/rc5.d/S02mysql' ]; then
    cd /etc/rc5.d
    ${LN} -s ../init.d/mysql S02mysql 
fi

if [ ! -f '/etc/rc6.d/K01mysql' ]; then
    cd /etc/rc6.d
    ${LN} -s ../init.d/mysql K01mysql 
fi


# ----------------------------------------------------------------------


exit

shell> bin/mysqld_safe --user=mysql &
# Next command is optional
shell> cp support-files/mysql.server /etc/init.d/mysql.server

