#!/bin/bash

# TODO make sure we can run docker in this server

install_docker () {
# Remove the lock
  set +e
  rm /var/lib/dpkg/lock > /dev/null
  rm /var/cache/apt/archives/lock > /dev/null
  dpkg --configure -a
  set -e

  # Required to update system
  apt-get update
  apt-get -y install wget lxc iptables curl

  # Install docker
  wget -qO- https://get.docker.com/ | sh
  usermod -a -G docker ${USER}

  service docker start || service docker restart
}

minimumMajor=1
minimumMinor=13

# Is docker already installed?
set +e
hasDocker=$(docker version | grep "version")
serverVersion=$(docker version --format '{{.Server.Version}}')
parsedVersion=( ${serverVersion//./ })
majorVersion="${parsedVersion[0]}"
minorVersion="${parsedVersion[1]}"
echo $serverVersion
echo "Major" $majorVersion
echo "Minor" $minorVersion
set -e

if [ ! "$hasDocker" ]; then
  install_docker

elif [ "$minimumMajor" -gt "$majorVersion" ]; then
  echo "major wrong"
  install_docker

elif [ "$minimumMajor" -eq "$majorVersion" ] && [ "$minimumMinor" -gt "$minorVersion" ]; then
  echo "minor wrong"
  install_docker
else
  # Start docker if it was stopped. If docker is already running, the exit code is 1
  service docker start || true
fi

# TODO make sure docker works as expected
