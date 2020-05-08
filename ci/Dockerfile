FROM alpine:3.10

ENV DUB_BRANCH "v1.20.1"
ENV RDMD_BRANCH "v2.091.0"

RUN apk add --no-cache llvm5-libs g++ binutils-gold clang \
    llvm8-libs llvm8-static llvm8-dev \
    cmake ninja zlib-dev curl-dev curl-static openssl openssl-dev git make

# build ldc2 ########################################################

ADD https://github.com/ldc-developers/ldc/releases/download/v1.13.0/ldc2-1.13.0-alpine-linux-x86_64.tar.xz /ldc-bin.tar.xz
RUN tar xf ldc-bin.tar.xz

# TODO: use environment variable from travis for LDC version
ADD https://github.com/ldc-developers/ldc/releases/download/v1.21.0/ldc-1.21.0-src.tar.gz /ldc-src.tar.xz
RUN tar xf ldc-src.tar.xz

RUN mkdir /ldc-1.21.0-src/build \
    && cd /ldc-1.21.0-src/build \
    && cmake -G Ninja .. -DCMAKE_BUILD_TYPE=Release \
        -DD_COMPILER=/ldc2-1.13.0-alpine-linux-x86_64/bin/ldmd2 \
    && ninja -j2 \
    && ninja install

# build dub ##########################################################

RUN git clone --single-branch --branch ${DUB_BRANCH} https://github.com/dlang/dub \
    && cd dub \
    && ldmd2 -run build.d \
    && cp bin/dub /usr/local/bin/

# build rdmd #########################################################

RUN git clone --single-branch --branch ${RDMD_BRANCH} https://github.com/dlang/tools \
    && cd tools \
    && sed -i "s|^DMD = .*$|DMD = ldmd2|" posix.mak \
    && sed -i "s|^INSTALL_DIR = .*$|INSTALL_DIR = $PWD|" posix.mak \
    && make -f posix.mak install \
    && cp bin/rdmd /usr/local/bin/


COPY docker.build.sh /docker.build.sh
RUN chmod +x /docker.build.sh

ENTRYPOINT [ "/docker.build.sh" ]
