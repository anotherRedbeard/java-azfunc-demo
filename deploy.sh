#!/bin/bash

# Variables
SUBSCRIPTION_ID="<subscription-id>"
LOCATION="<location>"
RESOURCE_GROUP="<resource-group-name>"
FUNCTION_APP_NAME="<function-app-name>"
ARTIFACT_ID="<artifact-name-must-match-pom.xml>"
FUNCTION_APP_PATH="target/azure-functions/$ARTIFACT_ID"
ZIP_FILE="$FUNCTION_APP_PATH/functionapp.zip"

# Function to display usage
usage() {
    echo "Usage: deploy.sh all|infra|function"
}

# Function to deploy infrastructure
deploy_infra() {
    echo "Deploying infra"
    az deployment sub create --subscription $SUBSCRIPTION_ID --location $LOCATION --name java-azfunction-deploy --parameters ./iac/bicep/create-java-function-all.dev.bicepparam
    #az deployment group create --resource-group red-scus-java-azfuncdemo-rg --parameters ./iac/bicep/update-app-settings.dev.bicepparm
}

# Function to package function app
package_function() {
    echo "Packaging function app"
    mvn clean package -Pdev -s ./settings.xml
    if [ $? -ne 0 ]; then
        echo "Failed to package function app"
    fi

    echo "Creating ZIP file"
    cd $FUNCTION_APP_PATH
    zip -r functionapp.zip *
    cd ../../..
}

# Function to deploy function app
deploy_function() {
    echo "Deploying function app"
    az functionapp deployment source config-zip \
      --resource-group $RESOURCE_GROUP \
      --name $FUNCTION_APP_NAME  \
      --src $ZIP_FILE
    if [ $? -ne 0 ]; then
        echo "Failed to deploy function app"
    fi
}

if [ -z "$1" ]; then
    usage
fi

if [ "$1" == "all" ]; then
    echo "Deploying all"
    deploy_infra
    package_function
    deploy_function
elif [ "$1" == "infra" ]; then
    deploy_infra
elif [ "$1" == "function" ]; then
    package_function
    deploy_function
else
    usage
fi