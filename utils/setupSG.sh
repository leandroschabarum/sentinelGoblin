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
[[ -f SG_globals.sh ]] && source SG_globals.sh || echo "< no SG_globals.sh file found >"
# checks for the existence of funcs file and sources from it, otherwise throws an error
[[ -f SG_funcs.sh ]] && source SG_funcs.sh || echo "< no SG_funcs.sh file found >"

if [[ "$(pwd)" == "${SG_BASE_DIR:?'SG_BASE_DIR not set'}" ]]
then
	echo "[change repo placement] current directory can not be the same as $SG_BASE_DIR" && exit 1
fi

# cheeky way to show application logo ^^
[[ -f .logoSG ]] && cat .logoSG

makeLog "${SG_LOG_FILE:?'SG_LOG_FILE not set'}"

if [[ ! -d "${SG_BASE_DIR:?'SG_BASE_DIR not set'}" ]]
# setting up base directory
then
	if ! mkdir -p "$SG_BASE_DIR"
	then
		echo "< unable to create $SG_BASE_DIR >" >> "$SG_LOG_FILE"
		exit 1
	fi
	# redundant settings for ownership
	# again, kept in for sanity checks sake
	chmod 700 "$SG_BASE_DIR"
	chown root:root "$SG_BASE_DIR"

	if ! digCave
	then
		echo "< unable to create $SG_BASE_DIR/cave >" >> "$SG_LOG_FILE"
		exit 1
	fi

	mkdir "$SG_BASE_DIR/overwatch.d"
	touch "$SG_BASE_DIR/overwatch.d/SG.local"
	cat <<- EOF > "$SG_BASE_DIR/overwatch.d/SG.local"
	# SentinelGoblin extra overwatches can be set here
	# to add one, simple write: overwatch "<command>" "<name>"
	# to remove it just comment it out or delete the line
	EOF

	# copying source files to base directory
	cp SG_globals.sh SG_funcs.sh sentinelGoblin.sh LICENSE procNotif.sh "$SG_BASE_DIR/"

	# setting up systemd service file
	cp sentinelGoblin.service /lib/systemd/system/
	ln -s /lib/systemd/system/sentinelGoblin.service /etc/systemd/system/
fi

if [[ ! -f "$SG_BASE_DIR/${SG_CONF_FILE:?'SG_CONF_FILE not set'}" ]]
# setting up configuration file
then
	touch "$SG_BASE_DIR/$SG_CONF_FILE"
	cat <<- EOF > "$SG_BASE_DIR/$SG_CONF_FILE"
	#### main configuration file for sentinelGoblin ####

	# cycle_delay refers to how long the script will sleep
	# after running all overwatches (Defaults to 3 seconds)
	cycle_delay=1 #seconds

	# Telegram chat bot information for notifications
	token=''
	chatid=''
	EOF

	echo "< configuration file at $SG_BASE_DIR/$SG_CONF_FILE needs to be edited >"
fi

echo "< finished setting up sentinelGoblin >"