#!/bin/bash
set -ev

echo "Running local build test."

# build nxgipd2mqtt
docker run -it --rm --privileged --name "nxgipd2mqtt" \
    -v ~/.docker:/root/.docker \
    -v "$(pwd)":/docker \
    hassioaddons/build-env:latest \
    --target "nxgipd2mqtt" \
    --tag-test \
    --armhf \
    --from "homeassistant/{arch}-base" \
    --author "Org" \
    --doc-url "https://github.com/orgjvr/hassio-nxgipd2mqtt" \
    --parallel
