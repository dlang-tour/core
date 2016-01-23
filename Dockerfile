FROM busybox

MAINTAINER "André Stein <andre.stein.1985@gmail.com>"

EXPOSE 8080

COPY dlang-tour /dlang-tour
COPY config.docker.yml /config.yml
COPY public /public

CMD [ "/dlang-tour" ]
