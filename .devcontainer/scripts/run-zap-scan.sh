#!/bin/bash

TARGET=$1

echo "Running OWASP Zap API Scan on $TARGET"
docker run -v /workspace/.devcontainer:/zap/wrk/:rw --add-host=host.docker.internal:host-gateway -t owasp/zap2docker-stable zap-api-scan.py -t $TARGET -f openapi -z "-configfile /zap/wrk/.devcontainer/options.prop"
echo "Done."