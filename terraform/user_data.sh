#!/bin/bash

set -eux

apt-get update -y

apt-get install -y \
  docker.io \
  git \
  curl

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
  https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "Docker installation completed" > /var/log/devops-bootstrap.log
