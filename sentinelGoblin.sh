#!/bin/bash

############################################################
################ SCRIPT FOR sentinelGoblin #################
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

if [[ "$(id -u)" -ne 0 ]]
# enforces root privileges for execution
then
	echo ">>>> EXECUTION DENIED - ROOT ACCESS REQUIRED <<<<" && exit 1
fi

# checks for the existence of globals file and sources from it, otherwise throws an error
[[ -f "$(pwd)/globalsSG.sh" ]] && source "$(pwd)/globalsSG.sh" || echo "< no globalsSG.sh file found >"
# checks for the existence of funcs file and sources from it, otherwise throws an error
[[ -f "$(pwd)/funcsSG.sh" ]] && source "$(pwd)/funcsSG.sh" || echo "< no funcsSG.sh file found >"

while true
do
	# Log rotation happens when file reaches 15MB in size
	logRitual "$SG_LOG_FILE" 15000000
	[[ -f "$SG_BASE_DIR/$SG_CONF_FILE" ]] && source "$SG_BASE_DIR/$SG_CONF_FILE"

	# default overwatch routines
	overwatch "who" "logins"
	overwatch "iptables -L" "firewall"
	overwatch "netstat -tulpn | grep LISTEN" "openports"

	# also sources from overwatch.d/SG.local if it exists
	# so that you can add your own overwatches there
	# just be careful to not set the same overwatch name twice
	# PS. you can always put all overwatches there and leave this one empty
	[[ -f "$SG_BASE_DIR/overwatch.d/SG.local" ]] && source "$SG_BASE_DIR/overwatch.d/SG.local"
	sleep "${cycle_delay:=3}"
done
