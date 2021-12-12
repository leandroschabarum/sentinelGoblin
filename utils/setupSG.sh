#!/bin/bash

############################################################
##########    SCRIPT FOR sentinelGoblin SETUP     ##########
########## MUST BE EXECUTED FROM SOURCE DIRECTORY ##########
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# shellcheck disable=SC1091
# shellcheck disable=SC2154

[[ -r .colors ]] && source .colors

# enforces root privileges for setup execution
if [[ "$(id -u)" -ne 0 ]]
then
	echo -e "${yellow}Requires root privileges to execute${reset}" >&1
	exit 1
fi

[[ -r SG_globals.sh ]] && source SG_globals.sh || echo -e "${red}ERROR: no SG_globals.sh file found${reset}" >&2
[[ -r SG_funcs.sh ]] && source SG_funcs.sh || echo -e "${red}ERROR: no SG_funcs.sh file found${reset}" >&2
[[ ! -r SG_globals.sh || ! -r SG_funcs.sh ]] && exit 1

if [[ "$(pwd)" == "${SG_BASE_DIR:?'ERROR: SG_BASE_DIR not set'}" ]]
then
	echo -e "${yellow}[change directories] current directory can not be the same as $SG_BASE_DIR${reset}" >&1
	exit 1
fi

# cheeky way to show application logo ^^
[[ -r .logo ]] && cat .logo
makeLog "${SG_LOG_FILE:?'ERROR: SG_LOG_FILE not set'}"

# setting up base directory
if [[ ! -d "$SG_BASE_DIR" ]]
then
	if ! mkdir -p "$SG_BASE_DIR"
	then
		echo -e "${red}ERROR: unable to create $SG_BASE_DIR${reset}" >&2
		exit 1
	fi
	# redundant settings for ownership
	chmod 700 "$SG_BASE_DIR"
	chown root:root "$SG_BASE_DIR"

	if ! digCave
	then
		echo -e "${red}ERROR: unable to create $SG_BASE_DIR/cave${reset}" >&2
		exit 1
	fi

	# creating overwatch.d directory and separate overwatch file
	mkdir "$SG_BASE_DIR/overwatch.d" && touch "$SG_BASE_DIR/overwatch.d/SG.local"
	cat <<- EOF > "$SG_BASE_DIR/overwatch.d/SG.local"
	# SentinelGoblin extra overwatches can be set here
	# to add one, simple write: overwatch "<command>" "<name>"
	# to remove it just comment it out or delete the line
	EOF

	# copying source files to base directory
	if ! cp SG_globals.sh SG_funcs.sh sentinelGoblin.sh LICENSE procNotif.sh "$SG_BASE_DIR/"
	then
		echo -e "${red}ERROR: unable to copy source files to $SG_BASE_DIR${reset}" >&2
		exit 1
	fi

	# setting up systemd service file
	if cp sentinelGoblin.service /lib/systemd/system/
	then
		if ! ln -s /lib/systemd/system/sentinelGoblin.service /etc/systemd/system/
		then
			echo -e "${red}ERROR: unable to link service file in /lib/systemd/system to /etc/systemd/system${reset}" >&2
			exit 1
		fi
	else
		echo -e "${red}ERROR: unable to copy service file to /lib/systemd/system/${reset}" >&2
		exit 1
	fi
fi

# setting up configuration file
if [[ ! -r "$SG_BASE_DIR/${SG_CONF_FILE:?'ERROR: SG_CONF_FILE not set'}" ]]
then
	touch "$SG_BASE_DIR/$SG_CONF_FILE"
	cat <<- EOF > "$SG_BASE_DIR/$SG_CONF_FILE"
	#### Main configuration file for sentinelGoblin ####

	# 'cycle_delay' refers to how long the script will sleep
	# after running all overwatches (Defaults to 3 seconds)
	cycle_delay=1 #seconds

	# Telegram chat bot information for notifications
	token=''
	chatid=''
	EOF

	echo -e "${cyan}ALERT: Configuration file at $SG_BASE_DIR/$SG_CONF_FILE needs to be edited${reset}" >&1
fi

echo -e "${green}Completed setup for sentinelGoblin${reset}" >&1
exit 0
