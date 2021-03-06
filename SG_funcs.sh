#!/bin/bash

############################################################
############### FUNCTIONS FOR sentinelGoblin ###############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# shellcheck disable=SC2010
# shellcheck disable=SC2012
# shellcheck disable=SC2030
# shellcheck disable=SC2031
# shellcheck disable=SC2154

# Function for creating log file
# $1  string (required)  full path to log file to be created
makeLog()
{
	local LOG_FILE_PATH
	# required positional argument check
	LOG_FILE_PATH="${1:?'MISSING ARG: log file absolute path argument not passed to makeLog() function call'}"
	[[ -z $LOG_FILE_PATH ]] && exit 1

	# if LOG_FILE_PATH does not exist or is not writable then
	# attempt to create it and change its permissions
	if [[ ! -w "${LOG_FILE_PATH:?'LOG_FILE_PATH not set'}" ]]
	then
		if ! touch "$LOG_FILE_PATH"
		then
			echo -e "${red}ERROR: unable to create $LOG_FILE_PATH${reset}" >&2
			return 1
		fi
		# redundant settings for ownership
		# set anyways for sanity check
		chmod 640 "$LOG_FILE_PATH"
		chown root:root "$LOG_FILE_PATH"
	fi

	return 0
}

# Function for log file rotation
# $1  string (required)  full path to log file
# $2  number (required)  max bytes size of log file
logRitual()
{
	local LOG_FILE_PATH MAX_SIZE CUR_SIZE COUNT LAST
	# expected positional arguments check
	LOG_FILE_PATH="${1:?'MISSING ARG: log file absolute path argument not passed to logRitual() function call'}"
	MAX_SIZE="${2:?'MISSING ARG: max bytes size argument not passed to logRitual() function call'}"
	[[ -z $MAX_SIZE ]] && exit 1

	# if LOG_FILE_PATH does not exist or is not writable
	# then default to creating it and returning 2
	if [[ -w "$LOG_FILE_PATH" ]]
	then
		CUR_SIZE="$(du --block=1 "$LOG_FILE_PATH" | cut -f 1)"

		if [[ "$CUR_SIZE" -gt "$MAX_SIZE" ]]
		then
			# check last rotation of log files suffix number
			COUNT="$(ls "$LOG_FILE_PATH."* | grep -c -E ".*\\.log\\.([0-9]+)$")"
			LAST="$(ls -t "$LOG_FILE_PATH."* | head -n1 | grep -o -E "([0-9]+)$")"
			# the idea here is very simple
			# if the last rotation log file is not equal to the count of all rotated log files
			# that means that something is not right and some files may have been deleted or modified (either name or content)
			# first example: file.log file.log.3 file.log.1 | second example: file.log file.log.1 file.log.3
			# file.log is the current log file, so it is skipped anyways
			# COUNT would be 2, but LAST would have been 3 or 1 (depends if file.log.1 was modified or not)
			# either case something went wrong, so we default to checking each individual file to not mess up the rotation log suffix
			# also, there can be a notification in place here, so that this behavior is reported, but there is also a catch ^^
			# if COUNT is equal to LAST, all is good right? hmmm, maybe not (simple condition explains it)
			if [[ "$COUNT" -ne "$LAST" ]]
			then
				for LOG in ls -t "$LOG_FILE_PATH."*
				do
					[[ "$(echo "$LOG" | grep -o -E "([0-9]+)$")" -gt "$LAST" ]] && LAST="$(echo "$LOG" | grep -o -E "([0-9]+)$")"
				done

				unset LOG
			fi

			if mv "$LOG_FILE_PATH" "$LOG_FILE_PATH.$((LAST++))"
			then
				makeLog "$LOG_FILE_PATH"
				# returns 0 if log rotation went ok
				return 0
			fi
			# returns 1 if there was no log rotation
			return 1
		fi
	else
		makeLog "$LOG_FILE_PATH"
		# returns 2 if there was no log file when logRitual call happened
		return 2
	fi
}

# Function for creating cave directory in order to hold overwatch output
digCave()
{
	if [[ ! -d "$SG_BASE_DIR/cave" ]]
	then
		if mkdir "$SG_BASE_DIR/cave"
		then
			# redundant settings for ownership
			# set anyways for sanity check
			chmod 700 "$SG_BASE_DIR/cave"
			chown root:root "$SG_BASE_DIR/cave"
			# all went ok
			return 0
		fi
		# something wrong happened
		return 1
	fi
	# no need to create cave directory
	return 0
}

# Function for Telegram notification messages
# $1  string (required)  message to be sent to Telegram chat
alert()
{
	# 'token' and 'chatid' variables come from configuration file
	# in cases when they are not set (empty) skips function execution
	[[ -z "${token}" || -z "${chatid}" ]] && return 2

	local MSG RESPONSE
	# expected positional argument check and message composition
	read -r -d '' MSG <<- EOF
	&#10071; <b>[$(hostname)]</b> <i>$(date +"%Y-%m-%d %H:%M:%S")</i>
	${1:?'MISSING ARG: message argument not passed to alert() function call'}
	EOF

	REQUEST_URL="https://api.telegram.org/bot${token}/sendMessage"
	# Telegram API request using curl and grep to retrieve confirmation that message was send successfully
	RESPONSE="$(curl --location --request GET "$REQUEST_URL" \
		--data-urlencode "chat_id=${chatid}" \
		--data-urlencode "parse_mode=HTML" \
		--data-urlencode "text=${MSG:?'ERROR: empty message'}" \
		2>&1)"

	# if no {"ok":true} response is received, defaults to returning failed notication status
	[[ "$(echo "${RESPONSE:='empty'}" | grep -o -E '"ok":( +)?[[:alnum:]]+[^,]' | cut -d ':' -f 2)" =~ true ]] && return 0
	echo "$(date +"[%Y-%m-%d %H:%M:%S]") failed to send Telegram notification <${RESPONSE:='empty'}>" >> "$SG_LOG_FILE" && return 1
}

# Function for checking if there were changes to output of overwatch
# $1  string (required)  updated filename with new contents
checkSum()
{
	local FILE NEW_HASH OLD_HASH
	# expected positional argument check
	FILE="${1:?'MISSING ARG: updated file argument not passed to checkSum() function call'}"

	if [[ -f "$SG_BASE_DIR/cave/${FILE##*/}_old" && -f "$SG_BASE_DIR/cave/${FILE##*/}" ]]
	# if both files exist (file && file_old) run the checksum to see if they have changed
	then
		NEW_HASH="$(sha256sum "$SG_BASE_DIR/cave/${FILE##*/}" | cut -d ' ' -f 1)"
		OLD_HASH="$(sha256sum "$SG_BASE_DIR/cave/${FILE##*/}_old" | cut -d ' ' -f 1)"
		# this result serves as a trigger only and can be used in an if statement
		[[ "$NEW_HASH" != "$OLD_HASH" ]] && return 0
	fi
	# no changes were detected
	return 1
}

# Function for returning changes to file contents stored in the cave
# $1  string (required)  updated filename with new contents
diffChanges()
{
	local FILE CHANGES
	# expected positional argument check
	FILE="${1:?'MISSING ARG: updated file argument not passed to diffChanges() function call'}"

	if checkSum "${FILE##*/}"
	# checks if there are differences between files
	then
		CHANGES="$(diff "$SG_BASE_DIR/cave/${FILE##*/}" "$SG_BASE_DIR/cave/${FILE##*/}_old")"
		alert "Changes were detected in <b>${FILE##*/}</b> overwatch"
		# changes are extracted and logged
		echo "$(date +"[%Y-%m-%d %H:%M:%S]") Changes were detected in ${FILE##*/} overwatch" >> "$SG_LOG_FILE"
		echo "${CHANGES:='ERROR: CHANGES variable is empty'}" >> "$SG_LOG_FILE"
	fi

	[[ -f "$SG_BASE_DIR/cave/${FILE##*/}" ]] && cp -a "$SG_BASE_DIR/cave/${FILE##*/}" "$SG_BASE_DIR/cave/${FILE##*/}_old"
	# by default, copy over to file_old the contents of file
	return 0
}

# Function for setting up overwatch on bash commands
# $1  string (required)  command to set overwatch
# $2  string (required)  filename for overwatch output
overwatch()
{
	local COMMAND OUTPUT
	# expected positional arguments check
	COMMAND="${1:?'MISSING ARG: command argument not passed to overwatch() function call'}"
	OUTPUT="${2:?'MISSING ARG: filename argument not passed to overwatch() function call'}"

	# first checks if there were changes from the previous overwatch
	diffChanges "${OUTPUT##*/}"

	# digCave is in place here for the occurence of the cave directory being deleted
	if digCave
	then
		# evaluates command passed as string and redirects its output to a file
		# keeps only basename for output file (case when path is given)
		if ! eval "$COMMAND > $SG_BASE_DIR/cave/${OUTPUT##*/}"
		then
			echo "$(date +"[%Y-%m-%d %H:%M:%S]") FAILED: $COMMAND > $SG_BASE_DIR/cave/${OUTPUT##*/}" >> "$SG_LOG_FILE"
			return 1
		fi
	fi

	return 0
}
