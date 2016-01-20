FROM busybox

MAINTAINER "André Stein <andre.stein.1985@gmail.com>"

EXPOSE 8080

COPY dlang-tour /dlang-tour
COPY config.yml /config.yml
COPY public /public

RUN sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /config.yml

CMD [ "/dlang-tour" ]
