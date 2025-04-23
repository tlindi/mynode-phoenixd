# build using custom Dockerfile
#
# export CACHED=0 # Turn of compiletime cache
export CACHED=1

# Without sudo
docker build --progress=plain \
  --build-arg CACHING=$(if [ "$CACHED" ]; then echo "0"; else date +%s; fi) \
  -f .docker/Dockerfile-auto \
  -t phoenixd-auto:latest . >> phoenixd-auto_build.log 2>&1 &

# With sudo 
sudo sh -c 'docker build --progress=plain \
  --build-arg CACHING=$(if [ "$CACHED" ]; then echo "0"; else date +%s; fi) \
  -f .docker/Dockerfile-auto \
  -t phoenixd-auto:latest . >> phoenixd-auto_build.log 2>&1 &'
