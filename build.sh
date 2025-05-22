set -eux
DOCKER_IMG=tanho63/vizbuzz
PACKAGE_VERSION=$(grep -Po "(?<=Version\: ).+" DESCRIPTION)
TODAY=$(date +'%Y_%m_%d')

docker build \
  -t "$DOCKER_IMG:latest" \
  -t "$DOCKER_IMG:$PACKAGE_VERSION" \
  -t "$DOCKER_IMG:$TODAY" \
  .

docker login
docker push "$DOCKER_IMG:latest"
docker push "$DOCKER_IMG:$PACKAGE_VERSION"
docker push "$DOCKER_IMG:$TODAY"
