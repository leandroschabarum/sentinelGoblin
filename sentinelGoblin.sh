#!/bin/bash

############################################################
################ SCRIPT FOR sentinelGoblin #################
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2154

[[ -r .colors ]] && source .colors

# enforces root privileges for execution
if [[ "$(id -u)" -ne 0 ]]
then
	echo -e "${yellow}Requires root privileges to execute${reset}" >&1
	exit 1
fi

[[ -r SG_globals.sh ]] && source SG_globals.sh || echo -e "${red}ERROR: no SG_globals.sh file found${reset}" >&2
[[ -r SG_funcs.sh ]] && source SG_funcs.sh || echo -e "${red}ERROR: no SG_funcs.sh file found${reset}" >&2
[[ ! -r SG_globals.sh || ! -r SG_funcs.sh ]] && exit 1

while true
do
	# Log rotation happens when file reaches 15MB in size
	logRitual "${SG_LOG_FILE:?'SG_LOG_FILE not set'}" 15000000
	[[ -r "${SG_BASE_DIR:?'SG_BASE_DIR not set'}/${SG_CONF_FILE:?'SG_CONF_FILE not set'}" ]] && source "$SG_BASE_DIR/$SG_CONF_FILE"

	# default overwatch routines
	overwatch "who" "logins"
	overwatch "iptables -L" "firewall"
	overwatch "netstat -tulpn | grep LISTEN" "openports"

	# also sources from overwatch.d/SG.local if it exists
	# so that you can add your own overwatches there
	# just be careful to not set the same overwatch name twice!
	# PS. you can always put all overwatches there and remove the ones here

	[[ -r "${SG_BASE_DIR:?'SG_BASE_DIR not set'}/overwatch.d/SG.local" ]] && source "$SG_BASE_DIR/overwatch.d/SG.local"
	
	sleep "${cycle_delay:=3}"
done
