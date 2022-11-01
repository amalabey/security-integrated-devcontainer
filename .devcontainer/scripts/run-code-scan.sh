#!/bin/bash

ENV_VAR_FILE=/workspace/.devcontainer/local.env
HORUSEC_ISSUES_FILE=security-issues.json

workingDir=$1
cd $workingDir
cwd=$(pwd)
echo "Current working directory: $workingDir"

if [ ! -f $ENV_VAR_FILE ]
then
    echo "SQ: Environment config not found. Skipping code scan"
else
    export $(cat $ENV_VAR_FILE | xargs) >/dev/null
    
    echo "Running horusec security scanner"
    horusec start -p /workspace -P $HOST_PROJECT_PATH --config-file-path=/workspace/.devcontainer/horusec-config.json -o="sonarqube" -O="$HORUSEC_ISSUES_FILE" --log-level=debug
    # sanitise horusec output to make it more sonarqube compatible
    horusec_output=$(cat $HORUSEC_ISSUES_FILE |  jq '.issues[].primaryLocation.filePath |= "/workspace/"+.' | jq '.issues[].primaryLocation.message |= sub("^.+detected:\\s"; "")')
    echo $horusec_output > $HORUSEC_ISSUES_FILE
    vuln_dlls=$(jq '.issues[].primaryLocation.filePath' security-issues.json | tr -d '"' | grep ".dll$" | tr '\n' ',')
    
    echo "SQ: Running sonar scan"
    dotnet sonarscanner begin /k:$SQ_PROJECT_KEY /d:sonar.login=$SQ_AUTH_TOKEN /d:sonar.host.url=http://sonarqube:9000 \
    /d:sonar.cs.vscoveragexml.reportsPaths=coverage.xml \
    /d:sonar.verbose=true \
    /d:sonar.scm.exclusions.disabled=true \
    /d:sonar.externalIssuesReportPaths=/workspace/$HORUSEC_ISSUES_FILE \
    /d:sonar.projectBaseDir=/workspace \
    /d:sonar.javascript.exclusions="node_modules" \
    /d:sonar.sources=$vuln_dlls

    dotnet build
    dotnet-coverage collect 'dotnet test' -f xml  -o 'coverage.xml'

    dotnet sonarscanner end /d:sonar.login=$SQ_AUTH_TOKEN
    echo "SQ: Done. SonarScan completed"

#     echo "DT: Running depedency scan"
#     repo_name=$(basename -s .git `git config --get remote.origin.url`)
#     sln_path=$(find /workspace -name *.sln)
#     dotnet CycloneDX $sln_path -o /tmp
#     curl -X "POST" "http://dtrack-apiserver:8080/api/v1/bom" \
#      -H 'Content-Type: multipart/form-data' \
#      -H "X-Api-Key: $DT_AUTH_TOKEN" \
#      -F "autoCreate=true" \
#      -F "projectName=$repo_name" \
#      -F "projectVersion=1" \
#      -F "bom=@/tmp/bom.xml"

#     # echo "DT: Done. Dependency scan completed"
fi

