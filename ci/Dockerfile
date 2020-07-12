FROM alpine:3.12

RUN apk add --no-cache g++ clang \
    zlib-dev zlib-static curl-dev curl-static openssl openssl-dev openssl-libs-static \
    ldc dub dtools-rdmd

COPY docker.build.sh /docker.build.sh
RUN chmod +x /docker.build.sh

ENTRYPOINT [ "/docker.build.sh" ]
