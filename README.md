# Fluent-Bit docker image for Raspberry Pi and UmbrelOS

This repo contais code for building custom Fluent-Bit docker image. It is being used in custom Fluent-Bit Umbrel-app for monitoring devices with umbrelOS including Raspberry Pi 5.

See: [drew1kun/umbrel-apps](https://github.com/drew1kun/umbrel-apps/)

### Build new image

The build process is handled by github actions and does auto-tagging the docker images according to the upstream version.

Any changes done to repo are being ignored by CI unless the `versions.yml` file modification is committed.

- Check the [upstream docker hub page](https://hub.docker.com/r/fluent/fluent-bit/tags) for new image tags
- Modify `FLUENT_BIT_VERSION` var in [distroless.Dockerfile](distroless.Dockerfile) using the latest tag (see [fluent-bit github repo](https://github.com/fluent/fluent-bit/tags))
- Sign and Commit

```bash
git commit -S -m "Bumped image version"
git push
```

### Manual build and test with docker

```bash
# Set current fluent-bit version:
fluentbit_version=5.0.0

# Build:
docker buildx build \
    --platform linux/arm64 \
    -f distroless.Dockerfile \
    -t drew1kun/fluentbit:${fluentbit_version}-distroless \
    --load .

# Test:
docker run --rm \
    drew1kun/fluentbit:${fluentbit_version}-distroless \
    --version
```

PROFIT

## IMPORTANT!

The image is intented to be as minimal as possible.
Check the list of enabled features in [distroless.Dockerfile](distroless.Dockerfile).

Currently:

```Dockerfile
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
```
