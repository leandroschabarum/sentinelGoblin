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

if [[ "$(pwd)" == "${SG_BASE_DIR:?'base directory variable not set'}" ]]
then
	echo "[change repo placement] current directory cannot be the same as $SG_BASE_DIR" && exit 1
fi

[[ -f .logoSG ]] && cat .logoSG
makeLog "${SG_LOG_FILE:?'log file variable not set'}"

if [[ ! -d "${SG_BASE_DIR:?'base directory variable not set'}" ]]
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

	cp globalsSG.sh funcsSG.sh sentinelGoblin.sh "$SG_BASE_DIR/"
	cp sentinelGoblin.service /lib/systemd/system/
	ln -s /lib/systemd/system/sentinelGoblin.service /etc/systemd/system/
fi

if [[ ! -f "$SG_BASE_DIR/${SG_CONF_FILE:?'config file variable not set'}" ]]
# setting up configuration file
then
	touch "$SG_BASE_DIR/$SG_CONF_FILE"
	cat <<- EOF > "$SG_BASE_DIR/$SG_CONF_FILE"
	# configuration file for sentinelGoblin

	# Telegram chat bot
	token='<fill_in_bot_token>'
	chatid='<fill_in_group_chat_id>'
	EOF

	echo "< configuration file at $SG_BASE_DIR/$SG_CONF_FILE needs to be edited >"
fi

echo "< finished setting up sentinelGoblin >"
