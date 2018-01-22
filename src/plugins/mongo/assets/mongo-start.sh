#!/bin/bash

MONGO_VERSION=<%= mongoVersion %>

set -e

mkdir -p <%= mongoDbDir %>
docker pull mongo:$MONGO_VERSION

set +e

docker update --restart=no mongodb
docker exec mongodb mongod --shutdown
sleep 2
docker rm -f mongodb

set -e

echo "Running mongo:<%= mongoVersion %>"

docker run \
  -d \
  --restart=always \
  --publish=127.0.0.1:27017:27017 \
  --volume=<%= mongoDbDir %>:/data/db \
  --volume=/opt/mongodb/mongodb.conf:/mongodb.conf \
  --name=mongodb \
  mongo:$MONGO_VERSION mongod -f /mongodb.conf
