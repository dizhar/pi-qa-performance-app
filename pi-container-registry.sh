#!/bin/bash
set -e

# Login & Push Docker image to private repo
DOCKER="/usr/bin/docker"

[[ "$*" == *"--docker"* ]] && DOCKER="docker"

echo "$*" 

# source 
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-service-principal

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME="pageintegrity"
SERVICE_PRINCIPAL_NAME="acr-service-principal"

# Service principal ID: 
SP_APP_ID="0386b843-9bd8-4631-8cdb-0fe34c354201"

# Service principal password
SP_PASSWORD="6bd7f967-4b9c-4003-b289-3f5cc27116f8"

# GitLab access token
GIT_ACCESS_TOKEN="2SnPM6GLJSgsWwQ2K6Yu"

REGISTRY="pageintegrity.azurecr.io"

function login() {
    # Log in to Docker with service principal credentials
    # $DOCKER login "${ACR_NAME}.azurecr.io" --username $SP_APP_ID --password $SP_PASSWORD

    # docker version 18.09 and above
    # echo "$SP_PASSWORD" | docker login -u "$SP_APP_ID" "$REGISTRY" --password-stdin

    # old docker version
    docker login "$REGISTRY" --username $SP_APP_ID --password $SP_PASSWORD
}
function build() {
    local repository=$1
    # local image_tag=${2:-"latest"}
    local dockerfile=${2:-"DOCKERFILE"}

    [[ -z "$repository" ]] && "Repository name cannot be empty." && exit 1

    # local registry="${ACR_NAME}.azurecr.io"
    # local registry="pageintegrity.azurecr.io"
    local image_name="$REGISTRY/$repository"

    echo "=================================================================="
    echo "Building image '$image_name'"
    echo "=================================================================="

    $DOCKER build --no-cache -f $dockerfile -t $image_name --build-arg GIT_ACCESS_TOKEN="$GIT_ACCESS_TOKEN" .
}

function contains (){
    local str=$1
    local substring=$2

    [[ "$str" == *"$substring"* ]] && echo "TRUE" || echo "FALSE"    
}


function push() {
    local repository="$1"
    local tag_list="$2"
    local dockerfile=${3:-"DOCKERFILE"}

    [[ -z "$repository" ]] && "Repository name cannot be empty." && exit 1

    local image_name="$REGISTRY/$repository"

    [[ $(contains $tag_list "latest") != "TRUE" ]] && tag_list="$tag_list latest"

    for tag in $tag_list; do
        echo "=================================================================="
        echo "Tagging image: '$image_name:$tag'"
        echo "=================================================================="

        $DOCKER tag "$image_name" "$image_name:$tag"
    
        echo "=================================================================="
        echo "Pushing image: '$image_name:$tag'"
        echo "=================================================================="

        $DOCKER push "$image_name:$tag"
    done
        
    # docker push $IMAGE_NAME:$CI_COMMIT_REF_NAME-$CI_PIPELINE_ID
}

function create_sp() {
    # Obtain the full registry ID for subsequent command args
    ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

    # Create the service principal with rights scoped to the registry.
    # Default permissions are for docker pull access. Modify the '--role'
    # argument value as desired:
    # acrpull:     pull only
    # acrpush:     push and pull
    # owner:       push, pull, and assign roles
    ROLE="acrpush"
    SP_PASSWORD=$(az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role $ROLE --query password --output tsv)
    SP_APP_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)

    # Output the service principal's credentials; use these in your services and
    # applications to authenticate to the container registry.
    echo "Service principal ID: $SP_APP_ID"
    echo "Service principal password: $SP_PASSWORD"
}

command=$1

case $command in
    "login" )
        login
        ;;
    "build" )
        build "$2" "$4"
        login
        push "$2" "$3" "$4"
        ;;
    "push" )
        push "$2" "$3" "$4"
        ;;

    * )
        echo "pi-container-registry.sh: Invalid command '$command'." 
esac
