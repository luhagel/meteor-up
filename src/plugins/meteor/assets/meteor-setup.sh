#!/bin/bash

mkdir -p /opt/<%= name %>/
mkdir -p /opt/<%= name %>/config
mkdir -p /opt/<%= name %>/tmp
chown ${USER} /opt/<%= name %> -R
