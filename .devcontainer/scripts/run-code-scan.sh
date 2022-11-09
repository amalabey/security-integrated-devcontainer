#!/bin/bash
WORKING_DIR=/workspace
ENV_VAR_FILE=$WORKING_DIR/.devcontainer/local.env

if [ ! -f $ENV_VAR_FILE ]
then
    echo "SQ: Environment config not found. Skipping code scan"
else
    export $(cat $ENV_VAR_FILE | xargs) >/dev/null


    echo "SQ: Running sonar scan"
    dotnet sonarscanner begin /k:$SQ_PROJECT_KEY /d:sonar.login=$SQ_AUTH_TOKEN /d:sonar.host.url=http://sonarqube:9000 \
    /d:sonar.verbose=true \
    /d:sonar.scm.exclusions.disabled=true \
    /d:sonar.projectBaseDir=$WORKING_DIR \
    /d:sonar.javascript.exclusions="node_modules" \
    /d:sonar.dependencyCheck.jsonReportPath="$WORKING_DIR/.devcontainer/dependency-check-report.json" \
    /d:sonar.dependencyCheck.htmlReportPath="$WORKING_DIR/.devcontainer/dependency-check-report.html" \
    /d:sonar.sarif.path=$WORKING_DIR/horusec-results.sarif,$WORKING_DIR/results_sarif.sarif

    dotnet build
    dotnet-coverage collect 'dotnet test' -f xml  -o 'coverage.xml'

    horusec start -D -p $WORKING_DIR -P $HOST_PROJECT_PATH --config-file-path=$WORKING_DIR/.devcontainer/horusec-config.json -o="sarif" -O="$WORKING_DIR/horusec-results.sarif" --log-level=debug
    checkov -d $WORKING_DIR -o sarif --output-file-path=$WORKING_DIR
    /usr/bin/dependency-check.sh -f JSON -f HTML -s $WORKING_DIR -o $WORKING_DIR/.devcontainer --disableAssembly --log=dep-check.log

    dotnet sonarscanner end /d:sonar.login=$SQ_AUTH_TOKEN
    echo "SQ: Done. SonarScan completed"
fi

