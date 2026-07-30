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
    zlib1g-dev \
    libcurl4-openssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

ARG FLUENT_BIT_VERSION=v5.0.0

RUN git clone --depth 1 --branch ${FLUENT_BIT_VERSION} \
    https://github.com/fluent/fluent-bit.git .

RUN rm -rf build && \
    cmake \
    -S . \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    # Enabled: \
    -DFLB_RELEASE=On \
    -DFLB_CONFIG_YAML=On \
    -DFLB_IN_SYSTEMD=On \
    -DFLB_IN_TAIL=On \
    -DFLB_IN_KMSG=On \
    -DFLB_OUT_SYSLOG=On \
    -DFLB_LUAJIT=On \
    -DFLB_RECORD_ACCESSOR=On \
    # Disabled - Basic: \
    -DFLB_JEMALLOC=Off \
    -DFLB_TLS=Off \
    -DFLB_WASM=Off \
    # Disabled - Others: \
    #-DFLB_AWS=Off \
    -DFLB_FILTER_GEOIP2=Off \
    -DFLB_FILTER_TENSORFLOW=Off \
    -DFLB_HTTP_CLIENT_DEBUG=Off \
    -DFLB_IN_HTTP=Off \
    -DFLB_OUT_DATADOG=Off \
    -DFLB_OUT_LOKI=Off \
    -DFLB_OUT_PROMETHEUS_EXPORTER=Off \
    -DFLB_OUT_INFLUXDB=Off \
    -DFLB_OUT_KAFKA=Off \
    -DFLB_OUT_HTTP=Off \
    -DFLB_OUT_ES=Off \
    -DFLB_OUT_OPENSEARCH=Off \
    -DFLB_OUT_STACKDRIVER=Off \
    -DFLB_OUT_AZURE=Off \
    -DFLB_OUT_S3=Off \
    -DFLB_OUT_CLOUDWATCH_LOGS=Off \
    -DFLB_OUT_KINESIS_FIREHOSE=Off \
    -DFLB_OUT_KINESIS_STREAMS=Off \
    -DFLB_FILTER_ECS=Off \
    -DFLB_FILTER_AWS=Off

RUN cmake --build build -j$(nproc)

RUN strip build/bin/fluent-bit

RUN mkdir -p /deps && \
    ldd /src/build/bin/fluent-bit | \
    awk '{ if ($3 ~ /^\//) print $3 }' | \
    xargs -r -I{} cp --parents {} /deps/

FROM gcr.io/distroless/base-debian12

COPY --from=builder /src/build/bin/fluent-bit /fluent-bit/bin/fluent-bit
COPY --from=builder /deps /

ENTRYPOINT ["/fluent-bit/bin/fluent-bit"]
