#!/bin/sh
# build docker and fhem image from scratch
if docker version 2>/dev/null ; then
   wget https://raw.githubusercontent.com/heinz-otto/raspberry/master/Docker/setupDocker.sh
   bash setupDocker.sh
fi
sudo -su $(id -un) <<HERE
if docker-compose version 2>/dev/null ; then
   wget https://raw.githubusercontent.com/heinz-otto/raspberry/master/Docker/setupDockerComposeV2.sh
   bash setupDockerComposeV2.sh
fi
mkdir -p "$HOME/docker"
docker build -t debianfhem https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/DockerfileDeb
docker run -v "$HOME/docker/fhem:/opt/fhem"  --name testfhem debianfhem init svn clean
docker container rm testfhem
HERE
echo 'sudo -su $(id -un) docker run -v "$HOME/docker/fhem:/opt/fhem" -p "8083:8083" --name testfhem debianfhem'
echo 'or logoff and logon again for further work with docker without sudo -su $(id -un)'