FROM alpine:edge

RUN apk add --no-cache g++ clang \
    zlib-dev curl-dev curl-static openssl openssl-dev make git \
    ldc dub dtools-rdmd

COPY docker.build.sh /docker.build.sh
RUN chmod +x /docker.build.sh

ENTRYPOINT [ "/docker.build.sh" ]
