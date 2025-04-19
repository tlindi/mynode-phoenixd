#!/bin/bash

source /usr/share/mynode/mynode_device_info.sh
source /usr/share/mynode/mynode_app_versions.sh

set -x
set -e
trap 'echo "An error occurred. Exiting."; exit 1' ERR

echo "==================== UNINSTALLING APP ===================="

# The app folder will be removed automatically after this script runs. You may not need to do anything here.

# TODO: Perform special uninstallation steps here

backup_phoenixd() {
    # Backup phoenixd data with version and datetime info
    #
    if [ ! -d /mnt/hdd/mynode/phoenixd ]; then
        echo "phoenixd datadir doesn't exist so can't backup."
        return 0
    fi

    cd /mnt/hdd/mynode/phoenixd || exit 1
    echo "Changed directory to $(pwd)"

	export BACKUP_PATH="../phoenixd_backup"

	if [ ! -d "$BACKUP_PATH" ]; then 
		mkdir -p "$BACKUP_PATH" || { echo "Backup path '$BACKUP_PATH' couldn't be created."; exit 1; }
		chown bitcoin:bitcoin "$BACKUP_PATH" || { echo "Backup path owner couldn't be set."; exit 1; }
	fi

    # phoenixd provided Dockerfile doesn't build phoenix-cli into docker so following doesn't work on v0.5.1
    # export BACKUP_PHOENIXD_VERSION=$(docker exec phoenixd bin/phoenix-cli --version | sed 's/phoenixd version /v/g')
    export BACKUP_PHOENIXD_VERSION=v0.5.1-patched

    export BACKUP_PHOENIXD_NODEID=$(ls *.db | head -1 | sed 's/phoenix.mainnet.//g' | sed 's/.db//g')

    export BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

    export BACKUP_FILE="$BACKUP_PATH/phoenixd-$BACKUP_PHOENIXD_VERSION-$BACKUP_PHOENIXD_NODEID-$BACKUP_TIMESTAMP.tar.gz"

    echo Backing up phoenixd data:
    echo source: $(pwd)
    echo destination: $BACKUP_FILE

    echo tar zcfv "$BACKUP_FILE" --exclude=*.log ./
    tar zcfv $BACKUP_FILE --exclude=*.log ./

    # data folder removal if backup succeeded
    if [ -f "$BACKUP_FILE" ]; then
        echo removing $(pwd)/phoenixd
		cd ..
        rm -rfv /mnt/hdd/mynode/phoenixd
    else
        echo Data removal skipped - backup file $BACKUP_FILE missing!
    fi
}

only_docker_remove() {
    docker rmi phoenixd:v1.5.0-patched
    docker rmi phoenixd:latest
}

# Start the backup process
backup_phoenixd

# Remove docker
only_docker_remove

echo "================== DONE UNINSTALLING APP ================="
