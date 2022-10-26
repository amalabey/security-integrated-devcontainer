#!/bin/bash

ENV_VAR_FILE=/workspace/.devcontainer/local.env

init_env_config() {
    printf "SQ_USER=admin\n" >> $ENV_VAR_FILE
    printf "SQ_PASSWORD=admin\n" >> $ENV_VAR_FILE
    printf "DT_AUTH_TOKEN=dt-api-key\n" >> $ENV_VAR_FILE
}

load_env_vars() {
    if [ ! -f $ENV_VAR_FILE ]
    then
        touch $ENV_VAR_FILE
        chmod 700 $ENV_VAR_FILE
        init_env_config
    fi
    export $(cat $ENV_VAR_FILE | xargs) >/dev/null
}

wait_for_sq() {
    max_retry=60
    counter=0
    until curl -f -u $SQ_USER:$SQ_PASSWORD "http://localhost:9000/api/projects/search?q=$project_name&format=json"
    do
        sleep 1
        [[ counter -eq $max_retry ]] && echo "Failed!" && exit 1
        echo "Trying again. Try #$counter"
        ((counter++))
    done
}

setup_sq_project() {
    project_name=$1
    
    echo "SQ: Wait untill sonarqube is up: $SQ_USER:$SQ_PASSWORD"
    wait_for_sq

    echo "SQ: Checking if project: $project_name exists"
    project_key="null"
    response=$(curl -f -u $SQ_USER:$SQ_PASSWORD "http://localhost:9000/api/projects/search?q=$project_name&format=json")
    if grep -q "$response" <<< "error";
    then
        >&2 echo "SQ: Failed to query projects: $response"
        exit 1
    fi

    project=$(echo $response | jq ".components[0]")
    if [ "$project" == "null" ] 
    then
        echo "SQ: Project: $project_name does not exist. Attempt to create it."
        response=$(curl -f -u $SQ_USER:$SQ_PASSWORD "http://localhost:9000/api/projects/create" -X POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        -d "project=$project_name&name=$project_name")
        if grep -q "$response" <<< "error";
        then
            >&2 echo "ERR: Failed to create the project: $response"
            exit 1
        fi

        project_key=$(echo $response | jq ".project.key")
    else
        echo "SQ: Project: $project_name already exists"
        project_key=$(echo $project | jq ".key")
    fi
    echo "SQ: Project key: $project_key"
    
    token_id=$(cat /proc/sys/kernel/random/uuid)
    response=$(curl -f -u $SQ_USER:$SQ_PASSWORD "http://localhost:9000/api/user_tokens/generate" -X POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        -d "name=$token_id")
    if grep -q "$response" <<< "error";
    then
        >&2 echo "ERR: Failed to create the token: $response"
        exit 1
    fi
    user_token=$(echo $response | jq ".token")
    echo "SQ: Generated user token: $user_token"

    if [ -z "$project_key" ]
    then
        >&2 echo "ERR: Project key is empty"
    else
        printf "SQ_PROJECT_KEY=$project_key\n" >> $ENV_VAR_FILE
    fi

    if [ -z "$user_token" ]
    then
        >&2 echo "ERR: User token is empty"
    else
        printf "SQ_AUTH_TOKEN=$user_token\n" >> $ENV_VAR_FILE
    fi

    
}

load_env_vars
env
echo "SQ: Start setting up the SQ project"
repo_name=$(basename -s .git `git config --get remote.origin.url`)
setup_sq_project $repo_name

echo "Scripts: Make scripts executable"
chmod +x /workspace/.devcontainer/scripts/post-commit.sh
chmod +x /workspace/.devcontainer/scripts/run-code-scan.sh
chmod +x /workspace/.devcontainer/scripts/run-secret-scan.sh

echo "Git: Copying post-commit.sh as post-commit git hook"
cp /workspace/.devcontainer/scripts/post-commit.sh /workspace/.git/hooks/post-commit

echo "Git: Installing GitLeaks as a pre-commit hook"
cd /workspace/.devcontainer/scripts
pre-commit install --allow-missing-config