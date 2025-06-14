# docker-nginx-web2py

[![Build Status](https://travis-ci.com/onezoom/docker-nginx-web2py.svg?branch=master)](https://travis-ci.com/onezoom/docker-nginx-web2py)
[![Layers](https://images.microbadger.com/badges/image/onezoom/docker-nginx-web2py.svg)](http://microbadger.com/images/onezoom/docker-nginx-web2py)

Docker container for Nginx with Web2py using python 3 on Ubuntu 24.04 based on [onezoom/docker-nginx](https://github.com/onezoom/docker-nginx/) derived from [madharjan/docker-nginx](https://github.com/madharjan/docker-nginx/)

To build, run `make build`, which will build both a normal and a `-min` version (web2py
without the extra welcom app etc). To release new versions of the normal and -min containers,
change the web2py version in the Makefile, and (if necessary) the first line of the Dockerfile,
then run `make release`, which will run a test suite (also available using `make test`) and,
if tests pass, attempt to push a release to docker.io. You may need to run `make clean` beforehand.
To specify building for a different platform or set of platforms (e.g. on Mac ARM),
specify e.g. `make build PLATFORM=linux/amd64,linux/arm64`.

## Features

* Environment variables to set admin password
* User-provided appconfig.ini file can be specified
* Minimal (for production deploy) version of container `docker-nginx-web2py-min` for Web2py without `admin`, `example` and `welcome`
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## Nginx 1.38.0 & Web2py 3.0.11 (docker-nginx-web2py)

### Environment

| Variable                  | Default | Example                                                                                    |
|---------------------------|---------|--------------------------------------------------------------------------------------------|
| WEB2PY_ADMIN              |         | Pa55w0rd                                                                                   |
| DISABLE_UWSGI             | 0       | 1 (to disable)                                                                             |
|                           |         |                                                                                            |
| INSTALL_PROJECT           | 0       | 1 (to enable)                                                                              |
| PROJECT_GIT_REPO          |         | [https://github.com/OneZoom/OZtree](https://github.com/OneZoom/OZtree) |
| PROJECT_GIT_TAG           | HEAD    | v5.1.4                                                                                     |
| PROJECT_APPCONFIG_INI_PATH|         | /etc/appconfig.ini                                                                         |

## Build

```bash
# clone project
git clone https://github.com/onezoom/docker-nginx-web2py
cd docker-nginx-web2py

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/web2py/applications/
sudo mkdir -p /opt/docker/web2py/log/

docker stop web2py
docker rm web2py

# run container
# Web2py include Admin, Example and Welcome
docker run -d \
  -e WEB2PY_ADMIN=Pa55word \
  -p 80:80 \
  -v /opt/docker/web2py/applications:/opt/web2py/applications \
  -v /opt/docker/web2py/log:/var/log/nginx \
  --name web2py \
  onezoom/docker-nginx-web2py:3.0.11

# run container
# Web2py Minimal
docker run -d \
  -e WEB2PY_ADMIN=Pa55word \
  -p 80:80 \
  -v /opt/docker/web2py/applications:/opt/web2py/applications \
  -v /opt/docker/web2py/log:/var/log/nginx \
  --name web2py \
  onezoom/docker-nginx-web2py-min:3.0.11
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=Web2py Framework

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/web2py/applications
ExecStartPre=-/bin/mkdir -p /opt/docker/web2py/log
ExecStartPre=-/usr/bin/docker stop web2py
ExecStartPre=-/usr/bin/docker rm web2py
ExecStartPre=-/usr/bin/docker pull onezoom/docker-nginx-web2py:2.21.1

ExecStart=/usr/bin/docker run \
  -e WEB2PY_ADMIN=Pa55w0rd \
  -p 80:80 \
  -v /opt/docker/web2py/applications:/opt/web2py/applications \
  -v /opt/docker/web2py/log:/var/log/nginx \
  --name  web2py \
  onezoom/docker-nginx-web2py:2.21.1

ExecStop=/usr/bin/docker stop -t 2 web2py

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable             | Default          | Example                                                                                    |
|----------------------|------------------|--------------------------------------------------------------------------------------------|
| PORT                 |                  | 8080                                                                                       |
| VOLUME_HOME          | /opt/docker      | /opt/data                                                                                  |
| NAME                 | ngnix            |                                                                                            |
|                      |                  |                                                                                            |
| WEB2PY_ADMIN         |                  | Pa55w0rd                                                                                   |
| WEB2PY_MIN           | true             | false                                                                                      |
|                      |                  |                                                                                            |
| INSTALL_PROJECT      | 0                | 1 (to enable)                                                                              |
| PROJECT_GIT_REPO     |                  | [https://github.com/OneZoom/OZtree](https://github.com/OneZoom/OZtree) |
| PROJECT_GIT_TAG      | HEAD             | v1.0                                                                                       |

### To deploy web projects

```bash
docker run --rm \
  -e PORT=80 \
  -e VOLUME_HOME=/opt/docker \
  -e VERSION=2.21.1 \
  -e WEB2PY_ADMIN=Pa55w0rd \
  -e WEB2PY_MIN=false \
  -e INSTALL_PROJECT=1 \
  -e PROJECT_GIT_REPO=https://github.com/OneZoom/OZtree \
  -e PROJECT_GIT_TAG=HEAD \
  onezoom/docker-nginx-web2py-min:3.0.11 \
  web2py-systemd-unit | \
  sudo tee /etc/systemd/system/web2py.service

sudo systemctl enable web2py
sudo systemctl start web2py
```

note that some projects may require an bespoke appconfig.ini file, e.g. to specify
a database to be used with this docker instance. This can be done by mounting
a fine in your docker image at (e.g.) /etc/appconfig.ini, then setting
PROJECT_APPCONFIG_INI_PATH to this file path, from where it will be moved into
the `private` directory of your web2py project, overwriting any existing
appconfig.ini file in there.