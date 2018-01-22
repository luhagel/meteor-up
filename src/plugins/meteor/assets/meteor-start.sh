#!/bin/bash

set -e

APP_DIR=/opt/<%=appName %>
IMAGE=mup-<%= appName.toLowerCase() %>

# save the last known version
cd $APP_DIR
if docker image inspect $IMAGE:latest >/dev/null; then
  echo "using image"
  rm -rf current || true
else
  echo "using bundle"
  rm -rf last
  mv current last || true

  # setup the new version
  mkdir current
  cp tmp/bundle.tar.gz current/

  docker rmi $IMAGE:previous || true
fi

if docker image inspect $IMAGE:previous >/dev/null; then
  echo "removing last"
  rm -rf last
fi

# start app
bash config/start.sh
