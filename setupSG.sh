#!/bin/bash

############################################################
##########    SCRIPT FOR sentinelGoblin SETUP     ##########
########## MUST BE EXECUTED FROM SOURCE DIRECTORY ##########
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

createLOG

if [[ ! -d "${BASE_DIR:?'base directory variable not set'}" ]]
# setting up base directory
then
	if ! mkdir -p "$BASE_DIR"
	then
		echo "< unable to create $BASE_DIR >" >> "$LOG_FILE"
	fi
	# redundant settings for ownership
	# again, kept in for sanity checks sake
	chmod 700 "$BASE_DIR"
	chown root:root "$BASE_DIR"

	# copying source files to base directory
	# fill in code \(^v^)/
fi

if [[ ! -f "$BASE_DIR/${CONFIG_FILE:?'config file variable not set'}" ]]
# setting up configuration file
then
	cp "$(pwd)/gold.conf" "$BASE_DIR/"
	# fill in code for configuration file \(^v^)/
fi
