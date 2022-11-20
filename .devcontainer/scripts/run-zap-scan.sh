#!/bin/bash

TARGET=$1

echo "Running OWASP Zap API Scan on $TARGET"
docker run --rm -v $HOST_PROJECT_PATH:/zap/wrk/:rw --add-host=host.docker.internal:host-gateway \
    -t owasp/zap2docker-stable zap-api-scan.py \
    -t $TARGET \
    -f openapi \
    -z "-configfile /zap/wrk/.devcontainer/options.prop"\
    -r zap-results.html \
    -d


echo "Done."