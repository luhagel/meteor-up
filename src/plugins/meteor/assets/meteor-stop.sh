#!/bin/bash

APPNAME=<%= appName %>

docker rm -f $APPNAME || :
docker rm -f $APPNAME-frontend || :
docker rm -f $APPNAME-nginx-letsencrypt || :
docker rm -f $APPNAME-nginx-proxy || :

docker network disconnect bridge -f $APPNAME || :
docker network disconnect bridge -f $APPNAME-frontend || :
docker network disconnect bridge -f $APPNAME-nginx-letsencrypt || :
docker network disconnect bridge -f $APPNAME-nginx-proxy || :
