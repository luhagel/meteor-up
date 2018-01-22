#!/bin/bash

mkdir -p /opt/<%= name %>/
mkdir -p /opt/<%= name %>/certs
mkdir -p /opt/<%= name %>/mounted-certs
mkdir -p /opt/<%= name %>/config
mkdir -p /opt/<%= name %>/config/vhost.d
mkdir -p /opt/<%= name %>/config/html

touch /opt/<%= name %>/config/shared-config.sh
touch /opt/<%= name %>/config/env.list
touch /opt/<%= name %>/config/env_letsencrypt.list

chown ${USER} /opt/<%= name %> -R
