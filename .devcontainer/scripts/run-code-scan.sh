#!/bin/bash

ENV_VAR_FILE=/workspace/.devcontainer/local.env

workingDir=$1
cd $workingDir
cwd=$(pwd)
echo "Current working directory: $workingDir"

if [ ! -f $ENV_VAR_FILE ]
then
    echo "SQ: Environment config not found. Skipping code scan"
else
    export $(cat $ENV_VAR_FILE | xargs) >/dev/null
    
    
    echo "SQ: Running sonar scan"
    dotnet sonarscanner begin /k:$SQ_PROJECT_KEY /d:sonar.login=$SQ_AUTH_TOKEN /d:sonar.host.url=http://sonarqube:9000 \
    /d:sonar.verbose=true \
    /d:sonar.scm.exclusions.disabled=true \
    /d:sonar.projectBaseDir=/workspace \
    /d:sonar.javascript.exclusions="node_modules" \
    /d:sonar.sarif.path=/workspace/.devcontainer/horusec-results.sarif,/workspace/.devcontainer/results_sarif.sarif

    dotnet build
    dotnet-coverage collect 'dotnet test' -f xml  -o 'coverage.xml'

    horusec start -D -p /workspace/src -P $HOST_PROJECT_PATH --config-file-path=/workspace/.devcontainer/horusec-config.json -o="sarif" -O="/workspace/.devcontainer/horusec-results.sarif" --log-level=debug
    checkov -d /workspace/src -o sarif --output-file-path=/workspace/.devcontainer

    dotnet sonarscanner end /d:sonar.login=$SQ_AUTH_TOKEN
    echo "SQ: Done. SonarScan completed"
fi

