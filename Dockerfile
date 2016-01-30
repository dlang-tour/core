FROM busybox

MAINTAINER "André Stein <andre.stein.1985@gmail.com>"

EXPOSE 8080

# Docker version updates here
ENV DOCKER_VERSION "1.9.1"

ADD https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION} /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker

COPY dlang-tour /dlang-tour
COPY config.docker.yml /config.yml
COPY public /public

CMD [ "/dlang-tour" ]
