#!/bin/bash

source /usr/share/mynode/mynode_device_info.sh
source /usr/share/mynode/mynode_app_versions.sh

set -x
set -e

echo "==================== UNINSTALLING APP ===================="

echo Setting trap to detect errors. Following is not error:
trap 'echo "An error occurred. Exiting."; exit 1' ERR

# Backup Phoenixd data before removal
if [ -d /mnt/hdd/mynode/phoenixd ]; then
    cd /mnt/hdd/mynode/phoenixd || exit 1
    echo "Changed directory to $(pwd)"

    export BACKUP_PATH="../phoenixd_backup"

    if [ ! -d "$BACKUP_PATH" ]; then 
        mkdir -p "$BACKUP_PATH" || { echo "Backup path '$BACKUP_PATH' couldn't be created."; exit 1; }
        chown bitcoin:bitcoin "$BACKUP_PATH" || { echo "Backup path owner couldn't be set."; exit 1; }
    fi

    export BACKUP_PHOENIXD_VERSION=$(cat "$BACKUP_PATH/phoenixd_version") 
    export BACKUP_PHOENIXD_NODEID=$(ls *.db | head -1 | sed 's/phoenix.mainnet.//g' | sed 's/.db//g')
    export BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    export BACKUP_FILE="$BACKUP_PATH/phoenixd-$BACKUP_PHOENIXD_VERSION-nodeid_$BACKUP_PHOENIXD_NODEID-$BACKUP_TIMESTAMP.tgz"

    echo "Backing up Phoenixd data..."
    echo "Source: $(pwd)"
    echo "Destination: $BACKUP_FILE"

    tar zcfv "$BACKUP_FILE" --exclude=*.log ./

    if [ -f "$BACKUP_FILE" ]; then
        echo "Removing Phoenixd data directory..."
        cd ..
        rm -rfv /mnt/hdd/mynode/phoenixd

        echo "Removing Phoenixd install version backup..."
        rm -rfv /mnt/hdd/mynode/phoenixd_backup/phoenixd_version
    else
        echo "Data removal skipped—backup file missing!"
    fi
else
    echo "Phoenixd datadir does not exist, skipping backup."
fi

# Remove Docker images related to Phoenixd
if docker images | grep -q phoenixd; then
    docker images | grep phoenixd | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
else
    echo "No Phoenixd images found, skipping Docker removal."
fi

echo "================== DONE UNINSTALLING APP ================="
