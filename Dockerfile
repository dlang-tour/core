ARG BASE_IMAGE=alpine:edge

# ----------------------------------- Base ----------------------------------- #
FROM $BASE_IMAGE AS base
RUN apk --no-cache add build-base coreutils dub dtools ldc openssl-dev zlib-dev
WORKDIR /src

# ------------------------ Gather dub package metadata ----------------------- #
FROM base as dub-cache
COPY . .
RUN mkdir /out \
  && find . -name "dub.sdl" -o -name "dub.json" -o -name "dub.selections.json" | \
    xargs cp -v --parents -t /out \
# Keep only the name and dependencies of each dub package manifest:
  && find /out -name "dub.sdl" | \
    xargs sed -i -n '/dependency\|name/p' \
# Create empty D files for each app to avoid the
# warning: '...package <name> contains no source files...'
  && mkdir -p /out/source && echo -e 'module app;\nvoid main() {}' > /out/source/app.d \
  ;

# ---------------------------------------------------------------------------- #
#                                   Builders                                   #
# ---------------------------------------------------------------------------- #

# ----------------------------- Dub Cache builder ---------------------------- #
FROM base AS dependencies-cache
COPY --from=dub-cache /out .
RUN dub --cache=local build

# ------------------------------- App builders ------------------------------- #
FROM dependencies-cache AS app-builder
COPY source ./source
COPY views ./views
COPY dub.sdl ./dub.sdl
RUN dub --cache=local build -c executable

FROM app-builder AS prod-builder
RUN dub --cache=local build -c executable --build=release-debug

# ------------------------------- Test runners ------------------------------- #
FROM app-builder AS unit-test-runner
COPY public ./public
RUN dub --cache=local test

FROM unit-test-runner AS integration-test-runner
COPY ./config.yml ./build
RUN apk add openblas-dev
RUN dub --cache=local run -- --sanitycheck

# ---------------------------------------------------------------------------- #
#                                    Runner                                    #
# ---------------------------------------------------------------------------- #
FROM $BASE_IMAGE as runner-cache
RUN apk --no-cache add ldc-runtime libexecinfo libgcc tzdata docker-cli
EXPOSE 8080
WORKDIR /app

FROM runner-cache AS runner
COPY --from=prod-builder /src/build/dlang-tour .
COPY docker/config.docker.yml .
COPY docker/docker.start.sh .
COPY public ./public
ENTRYPOINT [ "/app/docker.start.sh" ]
