#!/bin/bash

set -e

APP_DIR=/opt/<%=appName %>

cd $APP_DIR

# start app
bash config/start.sh 
