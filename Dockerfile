FROM busybox

MAINTAINER "André Stein <andre.stein.1985@gmail.com>"

EXPOSE 8080

# Docker version updates here
ENV DOCKER_VERSION "1.10.3"

ADD https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION} /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker

COPY dlang-tour /dlang-tour
COPY docker/config.docker.yml /config.yml.tmpl
COPY public /public
COPY docker/docker.start.sh /docker.start.sh
RUN chmod +x /docker.start.sh

ENTRYPOINT [ "/docker.start.sh" ]
