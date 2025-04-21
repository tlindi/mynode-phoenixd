./dist contains .tar.gz to be uploaded onto MyNodeBTC Marketplace Community App.

NO WARRANTIES OF ANY KIND!

TAKE, KEEP AND VERYFY BACKUP DATA RESTORABILITY BY YOURSELF!

![myNodeBTC-phoenixd](https://raw.githubusercontent.com/tlindi/mynode-phoenixd/refs/heads/main/screenshots/1.png)
# ToDo

### docker user recheck
* bitcoin / docker user setting must be mapped dunamicalle. 
is is not always 1001:1001 eg on Debian amd64 it was 1002:1002

### phoenix-cli needs 
* commandline wrapper bin to docker exec
* bash completitioner

### needs to info page template
* copy instructions from app.json
* backup button

# Changelog

### Change to user tlindi repo
* remove "patching" from install_phoenixd.sh,
* and use phoenixd upstream commits
* and use phoenixd upstream customized Dockerfile

### v0.5.1-patched+cli
* Enable phoenix-cli build by patching Dockerfile

### Commit f6236f0
* Fix start

### Initial Version
* Done
