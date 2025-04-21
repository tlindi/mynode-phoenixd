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

# use ACINQ docker
git clone http://www.github.com/acinq/phoenixd.git
cd phoenixd
git fetch --tags origin
git checkout $VERSION
#
# get 0.5.1 acinq patched commit (will do -patch "manually" at * below)
#git checkout 75ae285dd41833f58f409990635e84f2607c1a6e
#
# Create a local branch to avoid detached HEAD issues
git switch -c v0.5.1-patch
# Ensure the repository is strictly at v0.5.1 without pulling new commits
git fetch origin v0.5.1
git reset --hard v0.5.1

# (*) patch docker 0.5.1-patched which ACINQ forgot from release
#
sed -i 's/v0.5.0/v0.5.1/g' .docker/Dockerfile # version
sed -i 's/dc7f12417c70cc9af1e1f7d7f077910f8b198a98/ab9a026432a61d986d83c72df5619014414557be/g' .docker/Dockerfile # commithash
sed -i 's/distTar/jvmDistTar/g' .docker/Dockerfile # cradled task
sed -i 's/distributions\/phoenix-/distributions\/phoenixd-/g' .docker/Dockerfile # tar filename
sed -i 's/xvf phoenix-/xvf phoenixd-/g' .docker/Dockerfile # tar extract filename
##
# Add cli building into Dockerfile as additional gradlew task
#
sed -i '/&& \.\/gradlew jvmDistTar/i\
    && ./gradlew startScriptsForJvmPhoenix-cli \\' .docker/Dockerfile

# patch docker internal user to match MyNode bitcoin user
# so access rights on /mnt/hdd/mynode/phoenixd look similar to other apps ie "bitcoin:bitcoin"
sed -i 's/gid 1000/gid 1001/g' .docker/Dockerfile
sed -i 's/uid 1000/uid 1001/g' .docker/Dockerfile

# sudo docker ps -a
# sudo docker remove <CONTAINER_ID>
# docker image list
# docker rmi phoenixd:latest
#sudo -u bitcoin docker build -t phoenixd:latest .docker
#
docker images | grep phoenixd | awk '{print $3}' | xargs -r docker rmi -f
docker build -t phoenixd:v0.5.1-patched -f .docker/Dockerfile .
docker tag phoenixd:v0.5.1-patched phoenixd

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
echo "Continuing with installation..."

export PHOENIXD_BACKUP_DIR=/mnt/hdd/mynode/phoenixd_backup
if [ -d "$PHOENIXD_BACKUP_DIR" ]; then
    export BACKUP_FILE=$(ls -1 $PHOENIXD_BACKUP_DIR | awk -F'[_]' '{print $NF, $0}' | sort -n | awk '{print $2}' | tail -1)

    echo Restoring latest found backup: $PHOENIXD_BACKUP_DIR/$BACKUP_FILE
    tar xzvf "$PHOENIXD_BACKUP_DIR/$BACKUP_FILE" --strip-components=1 -C "$PHOENIXD_DATA_DIR"
else
    echo No restoreable backup was found. Starting with new phoenixd wallet.
fi

echo "================== DONE INSTALLING APP ================="