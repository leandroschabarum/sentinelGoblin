#!/bin/bash

############################################################
##########    SCRIPT FOR sentinelGoblin PURGE     ##########
########## MUST BE EXECUTED FROM SOURCE DIRECTORY ##########
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

if [[ "$(id -u)" -ne 0 ]]
# enforces root privileges for purge execution
then
	echo ">>>> EXECUTION DENIED - ROOT ACCESS REQUIRED <<<<" && exit 1
fi

# checks for the existence of globals file and sources from it, otherwise throws an error
[[ -f SG_globals.sh ]] && source SG_globals.sh || echo "< no SG_globals.sh file found >"

if [[ "$(pwd)" == "${SG_BASE_DIR:?'SG_BASE_DIR not set'}" ]]
then
	echo "[change repo placement] current directory can not be the same as $SG_BASE_DIR" && exit 1
fi

# removes service files
[[ -h /etc/systemd/system/sentinelGoblin.service ]] && rm /etc/systemd/system/sentinelGoblin.service
[[ -f /lib/systemd/system/sentinelGoblin.service ]] && rm /lib/systemd/system/sentinelGoblin.service
# removes source files
[[ -d "${SG_BASE_DIR:?'SG_BASE_DIR not set'}" ]] && rm -rf "$SG_BASE_DIR"
[[ -f "${SG_LOG_FILE:?'SG_LOG_FILE not set'}" ]] && rm "$SG_LOG_FILE"

echo "< sentinelGoblin has been purged from your system >"