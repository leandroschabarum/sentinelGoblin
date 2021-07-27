#!/bin/bash

############################################################
########### PROCESS NOTIFIER FOR sentinelGoblin ############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# checks for the existence of globals file and sources from it, otherwise throws an error
[[ -f globalsSG.sh ]] && source globalsSG.sh || echo "< no globalsSG.sh file found >"
# checks for the existence of funcs file and sources from it, otherwise throws an error
[[ -f funcsSG.sh ]] && source funcsSG.sh || echo "< no funcsSG.sh file found >"
# checks for the existence of configuration file and sources from it, otherwise throws an error
[[ -f "$SG_BASE_DIR/$SG_CONF_FILE" ]] && source "$SG_BASE_DIR/$SG_CONF_FILE" || echo "< no configuration file found >"

read -r -d '' INFO <<- EOF
>>> $(whoami)@$(hostname)
${1:?'empty message'}
EOF

alert "<b>$INFO</b>"
echo "$(date +"[%Y-%m-%d %H:%M:%S]") $INFO" >> "$SG_LOG_FILE"
