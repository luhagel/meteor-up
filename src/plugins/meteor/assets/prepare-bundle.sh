#!/bin/bash

set -e

APP_DIR=/opt/<%= appName %>
APPNAME=<%= appName %>
START_SCRIPT=$APP_DIR/config/start.sh
IMAGE=mup-<%= appName.toLowerCase() %>

build_failed() {
  docker start $APPNAME || true
  exit 2
}

set +e
docker pull <%= dockerImage %>
set -e

docker stop $APPNAME || true

cd $APP_DIR/tmp

rm -rf bundle
tar -xzf bundle.tar.gz

cd bundle

cat <<EOT > Dockerfile
FROM <%= dockerImage %>
RUN mkdir /built_app
COPY ./ /built_app
<% for(var key in env) { %>
ENV <%- key %>=<%- env[key] %>
<% } %>
RUN cd  /built_app/programs/server && \
    npm install --unsafe-perm
EOT

docker build -t $IMAGE:build . || build_failed

rm -rf bundle

docker start $APPNAME || true

docker tag $IMAGE:latest $IMAGE:previous || true
docker tag $IMAGE:build $IMAGE:latest
docker image prune -f
