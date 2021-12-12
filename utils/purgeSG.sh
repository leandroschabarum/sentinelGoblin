#!/bin/bash

############################################################
##########    SCRIPT FOR sentinelGoblin PURGE     ##########
########## MUST BE EXECUTED FROM SOURCE DIRECTORY ##########
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# shellcheck disable=SC1091
# shellcheck disable=SC2154

[[ -r .colors ]] && source .colors

# enforces root privileges for purge execution
if [[ "$(id -u)" -ne 0 ]]
then
	echo -e "${yellow}Requires root privileges to execute${reset}" >&1
	exit 1
fi

[[ -r SG_globals.sh ]] && source SG_globals.sh || echo -e "${red}ERROR: no SG_globals.sh file found${reset}" >&2
[[ ! -r SG_globals.sh ]] && exit 1

if [[ "$(pwd)" == "${SG_BASE_DIR:?'ERROR: SG_BASE_DIR not set'}" ]]
then
	echo -e "${yellow}[change directories] current directory can not be the same as $SG_BASE_DIR${reset}" >&1
	exit 1
fi

# removes service files
[[ -h /etc/systemd/system/sentinelGoblin.service ]] && rm /etc/systemd/system/sentinelGoblin.service
[[ -f /lib/systemd/system/sentinelGoblin.service ]] && rm /lib/systemd/system/sentinelGoblin.service
# removes source files
[[ -d "${SG_BASE_DIR:?'ERROR: SG_BASE_DIR not set'}" ]] && rm -rf "${SG_BASE_DIR}"

echo -e "${green}Completed purge of sentinelGoblin from your system${reset}" >&1
exit 0
