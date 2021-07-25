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

while true
do
	logRitual "$LOG_FILE" 15000000

	# default overwatch routines
	overwatch "who" "logins"
	overwatch "iptables -L" "firewall"
	overwatch "netstat -tulpn | grep LISTEN" "openports"

	# also sources from overwatch.d/SG.local if it exists
	# so that you can add your own overwatches there
	# just be careful to not set the same overwatch name twice
	[[ -f "$BASE_DIR/overwatch.d/SG.local" ]] && source "$BASE_DIR/overwatch.d/SG.local"
done