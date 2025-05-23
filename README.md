MyNodeBTC Community App from https://github.com/ACINQ/phoenixd/

./dist contains .tar.gz to be uploaded onto MyNodeBTC Marketplace Community App.

NO WARRANTIES OF ANY KIND!

TAKE, KEEP AND VERYFY BACKUP DATA RESTORABILITY BY YOURSELF!

![myNodeBTC-phoenixd](https://raw.githubusercontent.com/tlindi/mynode-phoenixd/refs/heads/main/screenshots/1.png)

# Known issues
* UID/GID of data dir must be 1000:1000. As workaround owner is switched from .service (docker-compose could help)
* Interrupted installation with empty datadir causes issue - uninstall creates empty backup file

# ToDo

### phoenix-cli needs
* commandline wrapper bin to docker exec
* bash completitioner

### needs App Data management
* data backup, restore and delete buttons

# Changelog

### version 0.6.0 (voi)
* phoenix-cli binary included in docker
* no more beta
* usage detailing

### version 0.5.1 (voimaa)
* use ACINQ dockerhub images
* added instructions also to info page
* more tested backup and restore of data dir

### docker user recheck
* bitcoin / docker user setting mapped dynamically

### backup restore error
tried to restore even backup folder contained no files

### Change to user tlindi repo
* remove "patching" from install_phoenixd.sh
* and use phoenixd upstream commits
* and use phoenixd upstream customized Dockerfile

### v0.5.1-patched+cli
* Enable phoenix-cli build by patching Dockerfile

### Commit f6236f0
* Fix start

### Initial Version
* Done
