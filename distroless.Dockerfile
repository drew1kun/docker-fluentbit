FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    gcc \
    g++ \
    flex \
    bison \
    pkg-config \
    libssl-dev \
    libyaml-dev \
    libsystemd-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

ARG FLUENT_BIT_VERSION=v5.0.9

RUN git clone --depth 1 --branch ${FLUENT_BIT_VERSION} \
    https://github.com/fluent/fluent-bit.git .

RUN rm -rf build && \
    cmake \
    -S . \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DFLB_ALL=Off \
    -DFLB_BINARY=On \
    -DFLB_CONFIG_YAML=On \
    -DFLB_FILTER_LUA=On \
    -DFLB_FILTER_MODIFY=On \
    -DFLB_HTTP_SERVER=On \
    -DFLB_IN_DOCKER=On \
    -DFLB_IN_DOCKER_EVENTS=On \
    -DFLB_IN_KMSG=On \
    -DFLB_IN_SYSTEMD=On \
    -DFLB_IN_UNIX_SOCKET=On \
    -DFLB_IN_TAIL=On \
    -DFLB_LUAJIT=On \
    -DFLB_OUT_SYSLOG=On \
    -DFLB_PARSER=On \
    -DFLB_RECORD_ACCESSOR=On \
    -DFLB_RELEASE=On \
    -DFLB_JEMALLOC=Off # this key makes it work with PAGE_SIZE=16k

RUN cmake --build build -j$(nproc)

RUN strip /src/build/bin/fluent-bit

RUN mkdir -p /deps && \
    ldd /src/build/bin/fluent-bit | \
    awk '{ if ($3 ~ /^\//) print $3 }' | \
    xargs -r -I{} cp --parents {} /deps/

FROM gcr.io/distroless/base-debian12

COPY --from=builder /src/build/bin/fluent-bit /fluent-bit/bin/fluent-bit
COPY --from=builder /deps /

ENTRYPOINT ["/fluent-bit/bin/fluent-bit"]
