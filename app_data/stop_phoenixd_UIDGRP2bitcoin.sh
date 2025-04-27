#!/bin/bash

# This will run on stop of the application

export PHOENIXD_DATA_DIR=/mnt/hdd/mynode/phoenixd

## Change data dir access rights to bitcoin:bitcoin to enable uninstall time backup
#
###
#  TEXT vs NUMBER UID/GID issue could (maybe) be solved with docker-compose
###
## Verify and fix ownership if necessary (TEXT)
CURRENT_OWNER=$(stat -c '%U' "$PHOENIXD_DATA_DIR")
CURRENT_GROUP=$(stat -c '%G' "$PHOENIXD_DATA_DIR")
## Verify and fix ownership if necessary (number)
#CURRENT_OWNER=$(stat -c '%u' "$PHOENIXD_DATA_DIR")
#CURRENT_GROUP=$(stat -c '%g' "$PHOENIXD_DATA_DIR")

## TEXT 
if [ "$CURRENT_OWNER" != "bitcoin" ] || [ "$CURRENT_GROUP" != "bitcoin" ]; then
    echo "Incorrect ownership detected ($CURRENT_OWNER:$CURRENT_GROUP). Updating to bitcoin:bitcoin"
    chown -R bitcoin:bitcoin "$PHOENIXD_DATA_DIR" || { echo "Failed to set ownership for $PHOENIXD_DATA_DIR"; exit 1; }
    echo "Ownership successfully updated to bitcoin:bitcoin"
else
    echo "Ownership is already correct: bitcoin:bitcoin"
fi
