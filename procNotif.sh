#!/bin/bash

############################################################
########### PROCESS NOTIFIER FOR sentinelGoblin ############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# shellcheck disable=SC1090
# shellcheck disable=SC1091

# checks for the existence of globals file and sources from it, otherwise throws an error
[[ -r SG_globals.sh ]] && source SG_globals.sh || echo "ERROR: no SG_globals.sh file found" >&2
# checks for the existence of funcs file and sources from it, otherwise throws an error
[[ -r SG_funcs.sh ]] && source SG_funcs.sh || echo "ERROR: no SG_funcs.sh file found" >&2
# checks for the existence of configuration file and sources from it, otherwise throws an error
[[ -r "${SG_BASE_DIR:?'SG_BASE_DIR not set'}/${SG_CONF_FILE:?'SG_CONF_FILE not set'}" ]] && source "$SG_BASE_DIR/$SG_CONF_FILE" || echo "ERROR: no configuration file found" >&2

[[ ! -r SG_globals.sh || ! -r SG_funcs.sh || ! -r "$SG_BASE_DIR/$SG_CONF_FILE" ]] && exit 1

# reads first positional argument passed
# to script and creates message block
read -r -d '' MSG <<- EOF
>>> $(whoami)@$(hostname)
${1:?'MISSING ARG: message must not be empty'}
EOF

alert "$MSG"
echo "$(date +"[%Y-%m-%d %H:%M:%S]") $MSG" >> "${SG_LOG_FILE:?'SG_LOG_FILE not set'}"
exit 0
