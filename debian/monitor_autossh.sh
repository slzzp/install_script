#!/bin/sh

AUTOSSH="/usr/bin/autossh"
CUT="/usr/bin/cut"
GREP="/bin/grep"
PS="/bin/ps"
SEQ="/usr/bin/seq"
TR="/usr/bin/tr"
WC="/usr/bin/wc"

# set monitor time is 60 seconds
export AUTOSSH_FIRST_POLL=60
export AUTOSSH_POLL=60

MAX_AUTOSSH=2

#
# NOTICES:
#
# 1. Follow parameter's order DO NOT CHANGE.
# 2. Per connection per autossh setting.
# 3. Each autossh's monitor port must even, odd port for reverse monitor port.
#    ex: 12340 12342 12344 ... etc.
# 4. Remember change MAX_AUTOSSH if more autossh setting.
# 5. crontab example for root: * * * * * root /path/monitor_autossh.sh
# 6. If you want to kill autossh, use kill -15 pid, then autossh's child ssh will be terminated, too.

AUTOSSH0="-f -M 12340 -N -R 2025:127.0.0.1:25 user@host"
AUTOSSH1="-f -M 12342 -N -R 2080:127.0.0.1:80 user@host"
AUTOSSH2="-f -M 12344 -N -R 2110:127.0.0.1:110 user@host"

for i in `${SEQ} 0 ${MAX_AUTOSSH}`; do
    NAME="AUTOSSH${i}"
    eval PARAM="\${${NAME}}"
    # echo "checking: autossh ${PARAM}"

    PARAMR=`echo "${PARAM}" | ${CUT} -c 4-`
    # echo ${PARAMR}

    PARAMRC=`${PS} ax | ${GREP} autossh | ${GREP} -- "${PARAMR}" | ${WC} -l | ${TR} -d ' '`
    # echo ${PARAMRC}

    if [ "0" = "${PARAMRC}" ]; then
        ${AUTOSSH} ${PARAM}
    fi
done
