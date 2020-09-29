#!/bin/bash
set -e

# source 
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-service-principal

# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
SERVICE_PRINCIPAL_NAME="acr-service-principal"
# Service principal ID: 
SP_APP_ID="0386b843-9bd8-4631-8cdb-0fe34c354201"
# Service principal password
SP_PASSWORD="6bd7f967-4b9c-4003-b289-3f5cc27116f8"
REGISTRY="pageintegrity.azurecr.io"

# docker version 18.09 and above
echo "$SP_PASSWORD" | docker login -u "$SP_APP_ID" "$REGISTRY" --password-stdin

# old docker version
# docker login "$REGISTRY" --username $SP_APP_ID --password $SP_PASSWORD
