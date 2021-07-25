#!/bin/bash

############################################################
################ SCRIPT FOR sentinelGoblin #################
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

if [[ "$(id -u)" -ne 0 ]]
# enforces root privileges for setup execution
then
	echo ">>>> EXECUTION DENIED - ROOT ACCESS REQUIRED <<<<" && exit 1
fi

# checks for the existence of globals file and sources from it, otherwise throws an error and exits with code 1
[[ -f "$(pwd)/globalsSG.sh" ]] && source "$(pwd)/globalsSG.sh" || echo "< no globalsSG.sh file found >" && exit 1
# checks for the existence of funcs file and sources from it, otherwise throws an error and exits with code 1
[[ -f "$(pwd)/funcsSG.sh" ]] && source "$(pwd)/funcsSG.sh" || echo "< no funcsSG.sh file found >" && exit 1


LOGGED=$(who | sha256sum | cut -d ' ' -f 1)

FIREWALL=$(iptables -L | sha256sum | cut -d ' ' -f 1)
overwatch "iptables -L" "firewall"

OPENPORTS=$(netstat -tulpn | grep LISTEN | sha256sum | cut -d ' ' -f 1)
overwatch "netstat -tulpn | grep LISTEN" "openports"

while true
do
	logRitual "$LOG_FILE"

	# default overwatch routines #

	sleep 1
done
