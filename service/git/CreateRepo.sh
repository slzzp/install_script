#!/bin/sh

# run as user 'root'

CHMOD=/bin/chmod
CHOWN=/usr/sbin/chown
GIT=/usr/local/bin/git
MKDIR=/bin/mkdir
WHOAMI=/usr/bin/whoami


if [ `${WHOAMI}` != 'root' ]; then
  echo "Error: you must be root."
  exit
fi

if [ -z "$1" ]; then
  echo "Error: no given repo name."
  exit
fi

cd ~git/repo

if [ -d "$1" -o -d "$1.git" ]; then
  echo "Error: repo '$1' is already exist."
  exit
fi


# build repo

${MKDIR} "$1"

cd "$1"

${GIT} init --bare --shared

${CHOWN} -R git:git .
${CHMOD} 700 .
