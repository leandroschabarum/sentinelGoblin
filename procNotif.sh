#!/bin/bash

############################################################
########### PROCESS NOTIFIER FOR sentinelGoblin ############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# checks for the existence of globals file and sources from it, otherwise throws an error
[[ -f SG_globals.sh ]] && source SG_globals.sh || echo "< no SG_globals.sh file found >"
# checks for the existence of funcs file and sources from it, otherwise throws an error
[[ -f SG_funcs.sh ]] && source SG_funcs.sh || echo "< no SG_funcs.sh file found >"
# checks for the existence of configuration file and sources from it, otherwise throws an error
[[ -f "${SG_BASE_DIR:?'SG_BASE_DIR not set'}/${SG_CONF_FILE:?'SG_CONF_FILE not set'}" ]] && source "$SG_BASE_DIR/$SG_CONF_FILE" || echo "< no configuration file found >"

# reads first positional argument passed
# to script and creates message block
read -r -d '' MSG <<- EOF
>>> $(whoami)@$(hostname)
${1:?'message must not be empty'}
EOF

alert "$MSG"
echo "$(date +"[%Y-%m-%d %H:%M:%S]") $MSG" >> "${SG_LOG_FILE:?'SG_LOG_FILE not set'}"
