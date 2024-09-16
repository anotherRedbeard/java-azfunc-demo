if [ -z "$1" ]; then
    echo "Usage: deploy.sh all|infra|function"
    #exit 1
fi

if [ "$1" == "all" ]; then
    echo "Deploying all"
    az deployment sub create --subscription <subscription-id> --location <location> --name python-azfunction-deploy --parameters ./iac/bicep/create-py-function-all.dev.bicepparam 
    func azure functionapp publish <function-app-name-in-azure> --dotnet-version 8.0
elif [ "$1" == "infra" ]; then
    echo "Deploying infra"
    az deployment sub create --subscription <subscription-id> --location <location> --name python-azfunction-deploy --parameters ./iac/bicep/create-py-function-all.dev.bicepparam 
elif [ "$1" == "function" ]; then
    echo "Deploying function"
    func azure functionapp publish <function-app-name-in-azure> 
else
    echo "Invalid option"
    #exit 1
fi