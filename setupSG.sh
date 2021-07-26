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

# checks for the existence of globals file and sources from it, otherwise throws an error
[[ -f "$(pwd)/globalsSG.sh" ]] && source "$(pwd)/globalsSG.sh" || echo "< no globalsSG.sh file found >"
# checks for the existence of funcs file and sources from it, otherwise throws an error
[[ -f "$(pwd)/funcsSG.sh" ]] && source "$(pwd)/funcsSG.sh" || echo "< no funcsSG.sh file found >"

[[ -f .logoSG ]] && cat .logoSG
makeLog "${LOG_FILE:?'log file variable not set'}"

if [[ ! -d "${BASE_DIR:?'base directory variable not set'}" ]]
# setting up base directory
then
	if ! mkdir -p "$BASE_DIR"
	then
		echo "< unable to create $BASE_DIR >" >> "$LOG_FILE"
		exit 1
	fi
	# redundant settings for ownership
	# again, kept in for sanity checks sake
	chmod 700 "$BASE_DIR"
	chown root:root "$BASE_DIR"

	if ! digCave
	then
		echo "< unable to create $BASE_DIR/cave >" >> "$LOG_FILE"
		exit 1
	fi

	mkdir "$BASE_DIR/overwatch.d"
	touch "$BASE_DIR/overwatch.d/SG.local"
	cat <<- EOF > "$BASE_DIR/overwatch.d/SG.local"
	# SentinelGoblin extra overwatches can be set here
	# to add one, simple write: overwatch "<command>" "<name>"
	# to remove it just comment it out or delete the line
	EOF

	cp globalsSG.sh funcsSG.sh sentinelGoblin.sh "$BASE_DIR/"
	cp sentinelGoblin.service /lib/systemd/system/
	ln -s /lib/systemd/system/sentinelGoblin.service /etc/systemd/system/
fi

if [[ ! -f "$BASE_DIR/${CONF_FILE:?'config file variable not set'}" ]]
# setting up configuration file
then
	touch "$BASE_DIR/$CONF_FILE"
	# fill in code for configuration file \(^v^)/
fi

echo "< finished setting up sentinelGoblin >"
