#!/bin/bash

APPNAME=<%= appName %>

docker rm -f $APPNAME || :
docker network disconnect bridge -f $APPNAME || :

docker rm -f $APPNAME-letsencrypt || :
