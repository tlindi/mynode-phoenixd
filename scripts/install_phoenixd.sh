#!/bin/bash

#** source /usr/share/mynode/mynode_device_info.sh
#** source /usr/share/mynode/mynode_app_versions.sh

set -x
#** set -e

#** echo Setting trap to detect errors. Following is not error:
#** trap 'echo "An error occurred. Exiting."; exit 1' ERR

#** echo "==================== INSTALLING APP ===================="

# The current directory is the app install folder and the app tarball from GitHub
# has already been downloaded and extracted. Any additional env variables specified
# in the JSON file are also present.

# TODO: Perform installation steps here

###
### LETS PATCH Dockerfile!!!
###
#
# Add zip to build stage, just to have a change of line here, it should any how be
# included on any architechture anyways already. If errors come we remove this
#
sed -i 's/\(RUN apt-get install -y --no-install-recommends bash git\)/\1 zip/' .docker/Dockerfile
grep 'bash git' .docker/Dockerfile

## Add lightnign-kmp
#
sed -i '/&& apt clean/a \
# \
# --- intentionally supposed to be empty lines here \
# \
# To prevent error: https://github.com/ACINQ/phoenixd/issues/170 \
# built lightning-kmp \
# see https://github.com/ACINQ/phoenixd/pull/169 \
# \
WORKDIR /lightning-kmp \' .docker/Dockerfile

sed -i '/WORKDIR \/lightning-kmp/a \
RUN git clone \\\
    https://github.com/ACINQ/lightning-kmp . \\\
    && ./gradlew publishToMavenLocal ' .docker/Dockerfile
# /sed

sed -i '/\&\& .\/gradlew publishToMavenLocal/a \
RUN ls -las ~/.m2/repository/fr/acinq/lightning ' .docker/Dockerfile

grep m2 .docker/Dockerfile

# use ACINQ docker
#git clone http://www.github.com/acinq/phoenixd.git

# use tlindi repo for patched v0.5.1 and Dockerfile
#** git clone http://www.github.com/tlindi/phoenixd.git

#** cd phoenixd
#** git fetch --tags origin
#git checkout $VERSION
#** git checkout $VERSION-native-way-v0.5.1-patched
#
# get 0.5.1 acinq patched commit (will do -patch "manually" at * below)
#git checkout 75ae285dd41833f58f409990635e84f2607c1a6e
#
#ARG PHOENIXD_BRANCH=v0.5.1
#ARM PHOENIXD_BRANCH=native-way-v0.5.1-patched
### Use specific ACINQ commit from 'Add support for linux arm64 target #157' (***)
#   https://github.com/ACINQ/phoenixd/pull/157
#
sed -i 's|PHOENIXD_BRANCH=.*|PHOENIXD_BRANCH=master|g' .docker/Dockerfile
sed -i 's|https://github.com/ACINQ/phoenixd|https://github.com/ACINQ/phoenixd|g' .docker/Dockerfile
sed -i 's/ARG PHOENIXD_COMMIT_HASH=.*/ARG PHOENIXD_COMMIT_HASH=ea893038b230a9675ef371d593b07718dfa7d3b5/' .docker/Dockerfile
#
# skip test COMMIT_HAS because above (***)
#
sed -z -i 's|\&\& test `git rev-parse HEAD` = ${PHOENIXD_COMMIT_HASH} \|\| exit 1 \\|\\|g' .docker/Dockerfile
# Create a local branch to avoid detached HEAD issues
#git switch -c v0.5.1-patched-with-cli
# Ensure the repository is strictly at v0.5.1 without pulling new commits
#git fetch origin v0.5.1-patched-with-cli
#git reset --hard v0.5.1-patched-with-cli

##
# Patch Casings in Dockerfile to fix ISSUE #172
# https://github.com/ACINQ/phoenixd/issues/172
#
#sed -i 's/^FROM/from/g' .docker/Dockerfiles
sed -i 's/AS BUILD/AS build/g' .docker/Dockerfile
sed -i 's/as FINAL/AS final/g' .docker/Dockerfile

### Lets prepare to native-way with using DistZip
# everywhere starting from fallback option "jvm"
#
sed -i 's|\./gradlew jvmDistTar|\./gradlew jvmDistZip|' .docker/Dockerfile
#
# here will come CASE CLAUSE to HANDLE ALL ARCHs
#
#sed -i '/&& \.\/gradlew jvmDistZip/i\
    # BEGIN ARCH-BASED BUILD LOGIC \\
    # ARG TARGET_PLATFORM \\
    # RUN if [ \"$TARGET_PLATFORM\" = \"linuxX64\" ]; then \\
    #     ./gradlew linuxX64DistZip; \\
    # elif [ \"$TARGET_PLATFORM\" = \"linuxArm64\" ]; then \\
    #     ./gradlew linuxArm64DistZip; \\
    # elif [ \"$TARGET_PLATFORM\" = \"macosX64\" ]; then \\
    #     ./gradlew macosX64DistZip; \\
    # elif [ \"$TARGET_PLATFORM\" = \"macosArm64\" ]; then \\
    #     ./gradlew macosArm64DistZip; \\
    # else \\
    #     echo \"Falling back to JVM distribution...\"; \\
    #     ./gradlew jvmDistZip; \\
    # fi \\
    # END ARCH-BASED BUILD LOGIC
#' .docker/Dockerfile
# /sed
grep DistZip .docker/Dockerfile
sed -i 's|^\([[:space:]]*\)&& ./gradlew jvmDistZip$|\1\&\& ./gradlew jvmDistZip --refresh-dependencies|' .docker/Dockerfile
grep DistZip .docker/Dockerfile
echo grepping
grep '^[[:space:]]*&& \.\/gradlew jvmDistZip --refresh-dependencies' .docker/Dockerfile
echo grep end

# Add cli building into Dockerfile as additional gradlew task
sed -i '/\&\& .\/gradlew jvmDistZip --refresh-dependencies/i \
    && ./gradlew startScriptsForJvmPhoenix-cli --refresh-dependencies &&' .docker/Dockerfile

#sed -i '/&& \.\/gradlew jvmDistZip --refresh-dependencies/a \
#    && ./gradlew startScriptsForJvmPhoenix-cli --refresh-dependencies ' .docker/Dockerfile
# /sed
grep '\-cli' .docker/Dockerfile

#
### convert Dockerfile tar binary extract commands to unzip
#
# Add unzip package install also to final stage
sed -i 's/\(RUN apt-get install -y --no-install-recommends bash\)$/\1 unzip/' .docker/Dockerfile
grep 'bash unzip' .docker/Dockerfile

# Modidy COPY LINE from tar to zip
#
sed -i 's|\(phoenixd/build/distributions/phoenixd-\*-jvm\)\.tar|\1.zip|' .docker/Dockerfile
grep .zip .docker/Dockerfile

#
# Modidy tar extract line from tar to #ZIP_PROCESS_MARKER
#
sed -i 's|RUN tar --strip-components=1 -xvf phoenixd-\*-jvm\.tar|#ZIP_PROCESS_MARKER|' \
.docker/Dockerfile
# sed end

grep MARKER .docker/Dockerfile

sed -i '/#ZIP_PROCESS_MARKER/ a\
# \
# Zip processing(multiline for dabuggin) \
# \
RUN echo user $(id) \&\&\
RUN pwd \&\&\
RUN mkdir -p /phoenix/bin \&\&\
RUN ls -lasR \&\&\
RUN unzip -jo phoenixd-\*-jvm.zip \*bin/phoenix\* -d /phoenix/bin \&\&\
RUN ls -lasR \
' .docker/Dockerfile

##sed -i 's|^#PHX_MARKER$|RUN echo user $(id) \&\& pwd \&\& mkdir -p /phoenix/bin \&\& ls -lasR \&\& unzip -jo phoenixd-*-jvm.zip *bin/phoenix* -d /phoenix/bin \&\& ls -lasR |' .docker/Dockerfile
#sed -i 's|^#PHX_MARKER$|RUN pwd \&\& ls -las \&\& unzip -l *.zip \&\& unzip -jo phoenixd-*-jvm.zip */bin/* -d . \&\&  |' .docker/Dockerfile
#sed -i 's|^#PHX_MARKER$|RUN mkdir -p /phoenix/bin \&\& unzip -j phoenixd-*-jvm.zip */bin/phoenix-cli* phoenix/bin \&\& chmod +x phoenix-cli |' .docker/Dockerfile
###sed -i 's|^#PHX_MARKER$|RUN mkdir -p /phoenix/bin \&\& unzip -q -j phoenixd-*-jvm.zip "*/bin/phoenixd" -d /phoenix/bin \&\& chmod +x /phoenix/bin/phoenixd|' .docker/Dockerfile
#
#sed -i 's|^#PHX_MARKER$|RUN echo user $(id) \&\& pwd \&\& mkdir -p /phoenix/bin \&\& ls -lasR \&\& unzip -jo phoenixd-*-jvm.zip *bin/phoenix* -d /phoenix/bin \&\& ls -lasR |' .docker/Dockerfile

##
# DEBUGGING BASH
##
sed -i 's|^ENTRYPOINT.*|ENTRYPOINT ["/bin/bash"]|' .docker/Dockerfile
#

###
#
# finetuning
#
###
# patch docker internal user to match MyNode bitcoin user
# so access rights on /mnt/hdd/mynode/phoenixd look similar to other apps ie "bitcoin:bitcoin"
#** export BTC_USR=$(id -u bitcoin)
#** export BTC_GRP=$(id -g bitcoin)
#** echo "BTC_USR=$BTC_USR, BTC_GRP=$BTC_GRP"
#** sed -i "s/gid 1000/gid $BTC_USR/g" .docker/Dockerfile
#** sed -i "s/uid 1000/uid $BTC_GRP/g" .docker/Dockerfile

# sudo docker ps -a
# sudo docker remove <CONTAINER_ID>
# docker image list
# docker rmi phoenixd:latest
#sudo -u bitcoin docker build -t phoenixd:latest .docker
#
#** docker images | grep phoenixd | awk '{print $3}' | xargs -r docker rmi -f
#** docker build -t phoenixd:v0.5.1-patched-with-cli -f .docker/Dockerfile .
#** docker tag phoenixd:v0.5.1-patched-with-cli phoenixd
docker rm -f phoenixd-jvm 2>/dev/null || true
docker images | grep phoenixd-jvm | awk '{print $3}' | xargs -r docker rmi -f

verify=$(docker images | grep phoenixd-jvm)
if [ -z "$verify" ]; then
    echo "Verify: No phoenixd-jvm images remain, as expected.";
else echo "Verify: phoenixd-jvm images still present:";
   echo "$verify";
fi

#docker build --build-arg TARGET_PLATFORM=jvm -t phoenixd-jvm -f .docker/Dockerfile .
docker build --progress=plain --build-arg TARGET_PLATFORM=jvm -t phoenixd-jvm -f .docker/Dockerfile .

verifyImage=$(docker images | grep phoenixd-jvm)
if [ -z "$verifyImage" ]; then
    echo "Verify: No phoenixd-jvm image built; please check build logs."
else
    echo "Verify: phoenixd-jvm image built successfully:"
    echo "$verifyImage"
fi

docker run --rm --name phoenixd-jvm phoenixd-jvm ls /phoenix/bin
docker run --rm --name phoenixd-jvm phoenixd-jvm ls /phoenix/bin | grep phoenix-cli

# create data dir and restore latest found backup
#
#** export PHOENIXD_DATA_DIR=/mnt/hdd/mynode/phoenixd
#** if [ ! -d "$PHOENIXD_DATA_DIR" ]; then
#**    mkdir -p "$PHOENIXD_DATA_DIR" || { echo "Failed to create $PHOENIXD_DATA_DIR"; exit 1; }
#**    echo "Successfully created $PHOENIXD_DATA_DIR"
#** fi

# Verify and fix ownership if necessary
#** CURRENT_OWNER=$(stat -c '%U' "$PHOENIXD_DATA_DIR")
#** CURRENT_GROUP=$(stat -c '%G' "$PHOENIXD_DATA_DIR")

#** if [ "$CURRENT_OWNER" != "bitcoin" ] || [ "$CURRENT_GROUP" != "bitcoin" ]; then
#**    echo "Incorrect ownership detected ($CURRENT_OWNER:$CURRENT_GROUP). Updating to bitcoin:bitcoin..."
#**    chown bitcoin:bitcoin "$PHOENIXD_DATA_DIR" || { echo "Failed to set ownership for $PHOENIXD_DATA_DIR"; exit 1; }
#**    echo "Ownership successfully updated to bitcoin:bitcoin."
#** else
#**    echo "Ownership is already correct: bitcoin:bitcoin."
#** fi
#** echo "Continuing with installation..."
: <<'EOF'
export PHOENIXD_BACKUP_DIR=/mnt/hdd/mynode/phoenixd_backup
if [ -d "$PHOENIXD_BACKUP_DIR" ]; then
    # Capture backup files, suppress error output if none are found
    export BACKUP_FILE=$(ls -1 "$PHOENIXD_BACKUP_DIR"/*.tar.gz 2>/dev/null | \
        sed 's/.*\(.\{15\}\)\.tar\.gz$/\1 &/' | \
        sort | tail -1 | cut -d' ' -f2-)

    if [ -n "$BACKUP_FILE" ]; then
        echo "Restoring latest found backup: $BACKUP_FILE"
        tar xzvf "$BACKUP_FILE" --strip-components=1 -C "$PHOENIXD_DATA_DIR"
    else
        echo "No restoreable backup was found. Starting with a new phoenixd wallet."
    fi
else
    echo "Backup directory $PHOENIXD_BACKUP_DIR does not exist. Starting with a new phoenixd wallet."
fi

echo "================== DONE INSTALLING APP ================="
EOF
