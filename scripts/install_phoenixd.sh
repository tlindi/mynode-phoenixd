#!/bin/bash

source /usr/share/mynode/mynode_device_info.sh
source /usr/share/mynode/mynode_app_versions.sh

set -x
set -e

echo Setting trap to detect errors. Following is not error:
trap 'echo "An error occurred. Exiting."; exit 1' ERR

echo "==================== INSTALLING APP ===================="

# The current directory is the app install folder and the app tarball from GitHub
# has already been downloaded and extracted. Any additional env variables specified
# in the JSON file are also present.

# TODO: Perform installation steps here

# Use ACINQ Official Docker images for amd64 and arm64
docker pull acinq/phoenixd:${VERSION}
docker tag acinq/phoenixd:${VERSION} phoenixd

# create data dir and restore latest found backup
#
export PHOENIXD_DATA_DIR=/mnt/hdd/mynode/phoenixd
if [ ! -d "$PHOENIXD_DATA_DIR" ]; then
    mkdir -p "$PHOENIXD_DATA_DIR" || { echo "Failed to create $PHOENIXD_DATA_DIR"; exit 1; }
    echo "Successfully created $PHOENIXD_DATA_DIR"
fi

# Verify and fix ownership if necessary
CURRENT_OWNER=$(stat -c '%U' "$PHOENIXD_DATA_DIR")
CURRENT_GROUP=$(stat -c '%G' "$PHOENIXD_DATA_DIR")

if [ "$CURRENT_OWNER" != "bitcoin" ] || [ "$CURRENT_GROUP" != "bitcoin" ]; then
    echo "Incorrect ownership detected ($CURRENT_OWNER:$CURRENT_GROUP). Updating to bitcoin:bitcoin..."
    chown bitcoin:bitcoin "$PHOENIXD_DATA_DIR" || { echo "Failed to set ownership for $PHOENIXD_DATA_DIR"; exit 1; }
    echo "Ownership successfully updated to bitcoin:bitcoin."
else
    echo "Ownership is already correct: bitcoin:bitcoin."
fi
echo "Continue installation..."

export PHOENIXD_BACKUP_DIR=/mnt/hdd/mynode/phoenixd_backup
if [ -d "$PHOENIXD_BACKUP_DIR" ]; then
    # Capture backup files, supress error output if none are found, and give name of nost recent
    export BACKUP_FILE=$(ls -1 "$PHOENIXD_BACKUP_DIR"/*.tar.gz 2>/dev/null | \
        sed -E 's/.*(.{15})\.tar\.gz$/\1|\0/' | \
        sort | tail -1 | cut -d'|' -f2-)

    if [ -n "$BACKUP_FILE" ]; then
        echo "Restoring latest found backup: $BACKUP_FILE"
        tar xzvf "$BACKUP_FILE" --strip-components=1 -C "$PHOENIXD_DATA_DIR"
    else
        echo "No restoreable backup was found. Starting with a new phoenixd wallet."
    fi
else
    echo "Backup directory $PHOENIXD_BACKUP_DIR does not exist. Creating..."
    if [ ! -d "$BACKUP_PATH" ]; then 
        mkdir -p "$BACKUP_PATH" || { echo "Backup path '$BACKUP_PATH' couldn't be created."; exit 1; }
        chown bitcoin:bitcoin "$BACKUP_PATH" || { echo "Backup path owner couldn't be set."; exit 1; }
    fi
        # save installed version info to backup purposes
	echo "$VERSION" > "$PHOENIXD_BACKUP_DIR\phoenixd_version"
	echo "Starting phoenixd wallet "$VERSION" and creating new wallet configuration."
fi

echo "================== DONE INSTALLING APP ================="
