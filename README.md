MyNodeBTC Community App from https://github.com/ACINQ/phoenixd/

./dist contains .tar.gz to be uploaded onto MyNodeBTC Marketplace Community App.

NO WARRANTIES OF ANY KIND!

TAKE, KEEP AND VERYFY BACKUP DATA RESTORABILITY BY YOURSELF!

![myNodeBTC-phoenixd](https://raw.githubusercontent.com/tlindi/mynode-phoenixd/refs/heads/main/screenshots/1.png)

# ToDo

### phoenix-cli needs
* commandline wrapper bin to docker exec
* bash completitioner

### needs
* backup button

# Changelog

### version 0.5.1 (branch 0.5.1-dockerhub)
* use acinq dockerhub images
* added instructions also to info page

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
