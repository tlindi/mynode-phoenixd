#!/bin/bash

# This will run prior to launching the application

## Fix data dir access rights to match phoenixd docker user (1000:1000)
echo "Running UID is: $(id)"
###
#  TEXT vs NUMBER UID/GID issue could (maybe) be solved with docker-compose
###
## Verify and fix ownership if necessary (TEXT)
#CURRENT_OWNER=$(stat -c '%U' "$PHOENIXD_DATA_DIR")
#CURRENT_GROUP=$(stat -c '%G' "$PHOENIXD_DATA_DIR")
## Verify and fix ownership if necessary (number)
CURRENT_OWNER=$(stat -c '%u' "$PHOENIXD_DATA_DIR")
CURRENT_GROUP=$(stat -c '%g' "$PHOENIXD_DATA_DIR")

## TEXT 
#if [ "$CURRENT_OWNER" != "bitcoin" ] || [ "$CURRENT_GROUP" != "bitcoin" ]; then
## Number 
if [ "$CURRENT_OWNER" != "1000" ] || [ "$CURRENT_GROUP" != "1000" ]; then
    echo "Incorrect ownership detected ($CURRENT_OWNER:$CURRENT_GROUP). Updating to bitcoin:bitcoin..."
## TEXT
#    chown bitcoin:bitcoin "$PHOENIXD_DATA_DIR" || { echo "Failed to set ownership for $PHOENIXD_DATA_DIR"; exit 1; }
    chown 1000:1000 "$PHOENIXD_DATA_DIR" || { echo "Failed to set owner:group for $PHOENIXD_DATA_DIR"; exit 1; }
## TEXT
#    echo "Ownership successfully updated to bitcoin:bitcoin."
    echo "Ownership successfully updated to 1000:1000."
else
## TEXT
#    echo "Ownership is already correct: bitcoin:bitcoin."
    echo "Ownership is already correct: 1000:1000."
fi
