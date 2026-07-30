# Fluent-Bit docker image for Raspberry Pi and UmbrelOS

This repo contais code for building custom Fluent-Bit docker image. It is being used in custom Fluent-Bit Umbrel-app for monitoring devices with umbrelOS including Raspberry Pi 5.

See: [drew1kun/umbrel-apps](https://github.com/drew1kun/umbrel-apps/)

### Build new image

The build process is handled by github actions and does auto-tagging the docker images according to the upstream version.

Any changes done to repo are being ignored by CI unless the `versions.yml` file modification is committed.

- Check the [upstream docker hub page](https://hub.docker.com/r/fluent/fluent-bit/tags) for new image tags
- Modify `versions.yml` with new version and digest
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

