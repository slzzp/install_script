#!/bin/sh

# Install ESXi 5.5U1 VMware Tools on FreeBSD 10.0 amd64

FETCH=/usr/bin/fetch
MAKE=/usr/bin/make
MKDIR=/bin/mkdir
MOUNT=/sbin/mount
PATCH=/usr/bin/patch
PKG=/usr/bin/pkg
RM=/bin/rm
TAR=/usr/bin/tar
UMOUNT=/sbin/umount

VMTOOLS_INSTALL_DIR=/tmp/vmtools
VMTOOLS_FILENAME=vmware-freebsd-tools.tar.gz


if [ ! -f "/mnt/${VMTOOLS_FILENAME}" ]; then
  ${MOUNT} -t cd9660 /dev/cd0 /mnt
fi

if [ ! -f "/mnt/${VMTOOLS_FILENAME}" ]; then
  echo 'Error: "select VM right click -> Guest -> Install/Upgrade VMware Tools" first.'
  exit
fi



# need compat6x-amd64
if [ ! -d '/usr/local/lib/compat' -o ! -e '/usr/local/lib/compat/libc.so.6' ]; then
  echo 'y' | ${PKG} install compat6x-amd64
fi



if [ -d "${VMTOOLS_INSTALL_DIR}" ]; then
  ${RM} -rf "${VMTOOLS_INSTALL_DIR}"
fi

${MKDIR} -p ${VMTOOLS_INSTALL_DIR}



cd ${VMTOOLS_INSTALL_DIR}

cp "/mnt/${VMTOOLS_FILENAME}" .

${UMOUNT} /mnt



for PATCHFILE in vmware-tools-distrib.diff vmblock-only.diff vmmemctl-only.diff vmmemctl-only55.diff; do
  if [ ! -e "${PATCHFILE}" ]; then
    ${FETCH} "http://ogris.de/vmware/${PATCHFILE}"
  fi

  if [ ! -e "${PATCHFILE}" ]; then
    echo "Error: get patch file '${PATCHFILE}' unsuccessful."
    exit
  fi
done



${TAR} xzf vmware-freebsd-tools.tar.gz



cd vmware-tools-distrib/

# Ignore Hunk #2 failed, ESXi 5.5U1 patched.
${PATCH} -p1 < ../vmware-tools-distrib.diff



cd lib/modules/source/

${TAR} xf vmblock.tar
${TAR} xf vmmemctl.tar



cd vmblock-only/

# ESXi 5.5U1 patched
# ${PATCH} -p1 < ../../../../../vmblock-only.diff

${MAKE}
${MAKE} install



cd ../vmmemctl-only

# ESXi 5.0 before
# ${PATCH} -p1 < ../../../../../vmmemctl-only.diff

# ESXi 5.5U1 patched
# ${PATCH} -p1 < ../../../../../vmmemctl-only55.diff

${MAKE}
${MAKE} install



cd ../../../../

./vmware-install.pl
