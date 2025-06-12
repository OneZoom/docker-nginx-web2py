#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

UWSGI_BUILD_PATH=/build/services/uwsgi

## Install uwsgi.
apt-get install -y --no-install-recommends \
  build-essential \
  libxml2-dev \
  python3-dev \
  python3-pip \
  pipx \
  unzip \
  rsync

pipx ensurepath
pipx install uwsgi

mkdir -p /etc/uwsgi
cp ${UWSGI_BUILD_PATH}/uwsgi.ini /etc/uwsgi/

mkdir -p /etc/service/uwsgi
cp ${UWSGI_BUILD_PATH}/uwsgi.runit /etc/service/uwsgi/run
chmod 750 /etc/service/uwsgi/run

mkdir -p /var/log/uwsgi

## Configure logrotate.
