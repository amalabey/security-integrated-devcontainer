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
    /d:sonar.cs.vscoveragexml.reportsPaths=coverage.xml
    dotnet build
    dotnet-coverage collect 'dotnet test' -f xml  -o 'coverage.xml'
    dotnet sonarscanner end /d:sonar.login=$SQ_AUTH_TOKEN
    echo "SQ: Done. SonarScan completed"

    echo "DT: Running depedency scan"
    repo_name=$(basename -s .git `git config --get remote.origin.url`)
    sln_path=$(find /workspace -name *.sln)
    dotnet CycloneDX $sln_path -o /tmp
    curl -X "POST" "http://dtrack-apiserver:8080/api/v1/bom" \
     -H 'Content-Type: multipart/form-data' \
     -H "X-Api-Key: $DT_AUTH_TOKEN" \
     -F "autoCreate=true" \
     -F "projectName=$repo_name" \
     -F "projectVersion=1" \
     -F "bom=@/tmp/bom.xml"
    
    echo "DT: Done. Dependency scan completed"
fi

