#!/bin/bash

############################################################
############### FUNCTIONS FOR sentinelGoblin ###############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################


makeLog()
# Function for creating log file
# $1 (required) ---> string | full path to log file to be created
{
	local LOG_FILE_PATH
	# expected positional argument check
	LOG_FILE_PATH="${1:?'log file full path argument not passed to makeLog() function call'}"

	if [[ ! -f "${LOG_FILE_PATH:?'log file variable not set'}" ]]
	# sets up log file
	then
		if ! touch "$LOG_FILE_PATH" || [[ ! -w "$LOG_FILE_PATH" ]]
		then
			echo "< unable to create/write $LOG_FILE_PATH >"
			return 1
		fi
		# redundant settings for ownership
		# kept in for nothing more than a simple sanity check
		chmod 640 "$LOG_FILE_PATH"
		chown root:root "$LOG_FILE_PATH"
	fi

	return 0
}


logRitual()
# Function for log file rotation
# $1 (required) ---> string | full path to log file
# $2 (required) ---> number | max bytes size of log file
{
	local LOG_FILE_PATH MAX_SIZE CUR_SIZE COUNT LAST
	# expected positional arguments check
	LOG_FILE_PATH="${1:?'log file full path argument not passed to logRitual() function call'}"
	MAX_SIZE="${2:?'max bytes size argument not passed to logRitual() function call'}"

	if [[ -f "$LOG_FILE_PATH" ]]
	# check existence of log file first
	# if file does not exist, default to creating it and returning 2
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

digCave()
# Function for creating cave directory in order to hold overwatch output
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


alert()
# Function for Telegram notification messages
# $1 (required) ---> string | message to be sent to Telegram chat
{
	local MSG RESPONSE OK
	# expected positional argument check
	MSG="${1:?'message argument not passed to alert() function call'}"
	MSG="<b>[!]</b> $(date +"%Y-%m-%d %H:%M:%S")\n$MSG"
	# 'token' and 'chatid' variables come from configuration file
	REQUEST_URL="https://api.telegram.org/bot${token:?'empty token'}/sendMessage?chat_id=${chatid:?'empty chatid'}&parse_mode=HTML&text=${MSG:?'empty message'}"
	# Telegram API request using curl and grep to retrieve confirmation that message was send successfully
	RESPONSE="$(curl --location --request GET "$REQUEST_URL" 2>&1)" #"grep -Eo '"ok":( +)?[[:alnum:]]+[^,]' | cut -d ':' -f 2)"
	# if no {"ok":true} response is received defaults to returning failed notication status
	OK="$(echo "$RESPONSE" | grep -Eo '"ok":( +)?[[:alnum:]]+[^,]' | cut -d ':' -f 2)"
	[[ "${OK:='false'}" =~ true ]] && return 0
	echo -e "Failed to send Telegram notification\\n$RESPONSE\\n$MSG" >> "$SG_LOG_FILE" && return 1  # DEBUG LINE
}


checkSum()
# Function for checking if there were changes to output of overwatch
# $1 (required) ---> string | updated filename with new contents
{
	local FILE NEW_HASH OLD_HASH
	# expected positional argument check
	FILE="${1:?'updated file argument not passed to checkSum() function call'}"

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


diffChanges()
# Function for returning changes to file contents stored in the cave
# $1 (required) ---> string | updated filename with new contents
{
	local FILE CHANGES
	# expected positional argument check
	FILE="${1:?'updated file argument not passed to diffChanges() function call'}"

	if checkSum "${FILE##*/}"
	# checks if there are differences between files
	then
		CHANGES="$(diff "$SG_BASE_DIR/cave/${FILE##*/}" "$SG_BASE_DIR/cave/${FILE##*/}_old")"
		alert "changes were detected in ${FILE##*/} overwatch"
		# changes are extracted and logged
		echo "$(date +"[%Y-%m-%d %H:%M:%S]") changes were detected in ${FILE##*/}" >> "$SG_LOG_FILE"
		echo "${CHANGES:?'CHANGES variable is empty'}" >> "$SG_LOG_FILE"
	fi

	[[ -f "$SG_BASE_DIR/cave/${FILE##*/}" ]] && cp -a "$SG_BASE_DIR/cave/${FILE##*/}" "$SG_BASE_DIR/cave/${FILE##*/}_old"
	# by default, copy over to file_old the contents of file
	return 0
}


overwatch()
# Function for setting up overwatch on bash commands
# $1 (required) ---> string | command to set overwatch
# $2 (required) ---> string | filename for overwatch output
{
	local COMMAND OUTPUT
	# expected positional arguments check
	COMMAND="${1:?'command argument not passed to overwatch() function call'}"
	OUTPUT="${2:?'filename argument not passed to overwatch() function call'}"

	# first checks if there were changes from the previous overwatch
	diffChanges "${OUTPUT##*/}"

	if digCave
	# digCave is in place here for the occurence of the cave directory being deleted
	then
		# evaluates command passed as string and redirects it to file output
		# keeps only basename for output file (case when path is given)
		if ! eval "$COMMAND > $SG_BASE_DIR/cave/${OUTPUT##*/}"
		then
			echo "$(date +"[%Y-%m-%d %H:%M:%S]") FAILED: $COMMAND > $SG_BASE_DIR/cave/${OUTPUT##*/}" >> "$SG_LOG_FILE"
			return 1
		fi
	fi

	return 0
}
