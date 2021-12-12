#!/bin/bash

############################################################
########### GLOBAL VARIABLES FOR sentinelGoblin ############
############################################################
# Created: Jul, 2021                                       #
# Creator: Leandro Schabarum                               #
# Contact: leandroschabarum.98@gmail.com                   #
############################################################

# shellcheck disable=SC2034

# ------------ default installation paths ------------ #
SG_BASE_DIR="/opt/sentinelGoblin"
SG_LOG_FILE="/var/log/sentinelGoblin.log"
SG_CONF_FILE="gold.conf"  # main configuration file
# ---------------------------------------------------- #


PROC_START_MSG="starting\\ sentinelGoblin\\ daemon..."
PROC_STOP_MSG="stopping\\ sentinelGoblin\\ daemon..."
