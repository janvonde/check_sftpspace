#!/bin/bash

#####
#
# Monitoring plugin to check free space on SFTP share
#
# Copyright (c) 2015 intranda GmbH
# Copyright (c) 2017 Jan Vonde <mail@jan-von.de>
#
#
# Usage: ./check_sftpsace.sh -h [host] -u [user] [ -o sftpOption ] -w [warn] -c [crit]
#
#
# Changelog:
#   2015-12-07: initial Version
#   2017-01-01: remove unused comments, fix WARN and CRIT, add perfdata
#   2020-07-30: add -o option
#
# For more information visit https://github.com/janvonde/check_sftpspace
#####


USAGE="Usage: check_sftpsace.sh -h [host] -u [user] [ -o sftpOption] -w [warn] -c [crit]"

if [ $# -ge 8 ]; then
	while getopts "h:u:o::w:c:"  OPCOES; do
		case $OPCOES in
			h ) SFTPHOST=$OPTARG;;
			u ) SFTPUSER=$OPTARG;;
			o ) SFTPOPTN=$OPTARG;;
			w ) WARN=$OPTARG;;
			c ) CRIT=$OPTARG;;
			? ) echo $USAGE
			     exit 1;;
			* ) echo $USAGE
			     exit 1;;
		esac
	done
else echo $USAGE; exit 3
fi



## error handling
type -P sftp &>/dev/null || { echo "ERROR: sftp is required but seems not to be installed.  Aborting." >&2; exit 1; }

## sftp extra opt
[ -z $SFTPOPTN ] && SFTPOPTN="port=22"


## get info and store
RESULT=$(echo "df -h" | sftp -o $SFTPOPTN ${SFTPUSER}@${SFTPHOST} 2>&1 | tail -1 | column -t)
read TOTAL USED AVAILABLE ROOT PERCENT <<< $RESULT
PERCENT=$(expr 100 - ${PERCENT/\%/})



## check and return info
if [ ${PERCENT} -lt ${CRIT} ]; then
        echo "CRITICAL: ${PERCENT}% free disk space: ${AVAILABLE} from ${TOTAL} |sftp_disk_usage=${USED};${WARN};${CRIT};0;${TOTAL}"
        exit 2
fi

if [ ${PERCENT} -lt ${WARN} ]; then
        echo "WARNING: ${PERCENT}% free disk space: ${AVAILABLE} from ${TOTAL} |sftp_disk_usage=${USED};${WARN};${CRIT};0;${TOTAL}"
        exit 1
fi


echo "OK - ${AVAILABLE} free space: (${USED} out of ${TOTAL} or ${PERCENT}% free) |sftp_disk_usage=${USED};${WARN};${CRIT};0;${TOTAL}"
exit 0

