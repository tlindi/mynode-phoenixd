# uncomment to disable build caching
export CACHEBUST=$(date +%s)
echo if not empty, CACHING disabled $CACHEBUST
cp -av ../Dockerfile .docker/ && bash ../scripts/install_phoenixd.sh
