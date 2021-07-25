#!/bin/bash

############################################################
############### FUNCTIONS FOR sentinelGoblin ###############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################


createLOG()
# Function for creating log file
# $1 (required) ---> string | full path to log file to be created
{
	local LOG_FILE_PATH
	# expected positional argument check
	LOG_FILE_PATH="${1:?'log file full path argument not passed to createLOG function call'}"

	if [[ ! -f "${LOG_FILE_PATH:?'log file variable not set'}" ]]
	# set up log file
	then
		if ! touch "$LOG_FILE_PATH"
		then
			echo "< unable to create $LOG_FILE_PATH >" && exit 1
		fi
		# redundant settings for privileges and ownership
		# kept in for nothing more than a simple sanity check
		chmod 644 "$LOG_FILE_PATH"
		chown root:root "$LOG_FILE_PATH"
	fi
}


logARCH()
# Function for log file rotation
# $1 (required) ---> string | full path to log file
# $2 (required) ---> number | max bytes size of log file
{
	local LOG_FILE_PATH MAX_SIZE CUR_SIZE COUNT LAST
	# expected positional arguments check
	LOG_FILE_PATH="${1:?'log file full path argument not passed to logARCH function call'}"
	MAX_SIZE="${2:?'max bytes size argument not passed to logARCH function call'}"

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
				createLOG "$LOG_FILE_PATH"
				# returns 0 if log rotation went ok
				return 0
			fi
			# returns 1 if there was no log rotation
			return 1
		fi
	else
		createLOG "$LOG_FILE_PATH"
		# returns 2 if there was no log file when logARCH call happened
		return 2
	fi
}
