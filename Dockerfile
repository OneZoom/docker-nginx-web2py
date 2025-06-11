FROM onezoom/docker-nginx:1.28.0
MAINTAINER OneZoom developers <mail@onezoom.org>

ARG VCS_REF
ARG WEB2PY_VERSION
ARG WEB2PY_MIN=false
ARG DEBUG=false

LABEL description="Docker container for Nginx with Web2py" os_version="Ubuntu ${UBUNTU_VERSION}" \
      org.label-schema.vcs-ref=${VCS_REF} org.label-schema.vcs-url="https://github.com/onezoom/docker-nginx-web2py"

ENV WEB2PY_VERSION=${WEB2PY_VERSION}
ENV WEB2PY_MIN=${WEB2PY_MIN}

RUN mkdir -p /build
COPY . /build

RUN chmod 755 /build/scripts/*.sh && /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/opt/web2py/applications", "/var/log/nginx"]

CMD ["/sbin/my_init"]

EXPOSE 80
