FROM ubuntu:16.04

MAINTAINER "André Stein <andre.stein.1985@gmail.com>"

EXPOSE 8080

RUN apt-get update && apt-get install -y \
 docker.io \
 && rm -rf /var/lib/apt/lists/*

RUN docker --version

COPY dlang-tour /dlang-tour
COPY docker/config.docker.yml /config.yml.tmpl
COPY public /public
COPY docker/docker.start.sh /docker.start.sh
RUN chmod +x /docker.start.sh

ENTRYPOINT [ "/docker.start.sh" ]
