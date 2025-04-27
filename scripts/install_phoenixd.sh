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

# WorkingDirectory for .service is needed
mkdir -p /opt/mynode/phoenixd || true 

# Use ACINQ Official Docker images for amd64 and arm64
docker pull acinq/phoenixd:${VERSION}
docker tag acinq/phoenixd:${VERSION} phoenixd

## create data dir
#
export PHOENIXD_DATA_DIR=/mnt/hdd/mynode/phoenixd
if [ ! -d "$PHOENIXD_DATA_DIR" ]; then
    mkdir -p "$PHOENIXD_DATA_DIR" || { echo "Failed to create data directory: $PHOENIXD_DATA_DIR"; exit 1; }
    echo "Successfully created data directory:"
	echo "$PHOENIXD_DATA_DIR"
fi

##  restore latest found backup
#
echo "Populate data dir from backup, if such exists."

export PHOENIXD_BACKUP_DIR=/mnt/hdd/mynode/phoenixd_backup
if [ ! -d "$PHOENIXD_BACKUP_DIR" ]; then
    echo "Previous backup directory not found at:"
	echo "$PHOENIXD_BACKUP_DIR so creating it..."
    mkdir -p "$PHOENIXD_BACKUP_DIR" || { echo "Backup path '$PHOENIXD_BACKUP_DIR' couldn't be created."; exit 1; }
#    chown bitcoin:bitcoin "$PHOENIXD_BACKUP_DIR" || { echo "Backup path owner couldn't be set."; exit 1; }
    chown 1000:1000 "$PHOENIXD_BACKUP_DIR" || { echo "Backup path owner:group couldn't be set."; exit 1; }
        
	echo "phoenixd "$VERSION" will open a new wallet."
else
    echo "Existing backup directory found:"
	echo "$PHOENIXD_BACKUP_DIR"
    # Capture backup files, supress error output if none are found, and give name of nost recent
    export BACKUP_FILE=$(ls -1 "$PHOENIXD_BACKUP_DIR"/*.tar.gz 2>/dev/null | \
        sed -E 's/.*(.{15})\.tar\.gz$/\1|\0/' | \
        sort | tail -1 | cut -d'|' -f2-)

    if [ -n "$BACKUP_FILE" ]; then
        echo "Restoring from latest backup file found:"
		echo "$BACKUP_FILE"
        tar xzvf "$BACKUP_FILE" --strip-components=1 -C "$PHOENIXD_DATA_DIR"
    else
        echo "No restoreable backup was found."
    fi
fi

echo $VERSION > "$PHOENIXD_BACKUP_DIR/phoenixd_version"

echo "================== DONE INSTALLING APP ================="
