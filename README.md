# Python Azure Functions Demo

This repository contains a demo project for Azure Functions using Java. The project includes a Queue and Blob based trigger, infrastructure deployment scripts, and configuration files.

## Getting Started

### Prerequisites

- [Java](https://code.visualstudio.com/docs/java/java-tutorial)
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Tech I'm using

- [Bicep Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/indexes/bicep/) to implement the IaC to support everything I need to demo this.
- *Coming Soon* [Github Actions](https://docs.github.com/en/actions/about-github-actions/understanding-github-actions) - This will be used to automatically deploy everything on commit instead of having to manually run the `deploy.<env>.sh` script.

### Deploying the Project to Azure

I have created a generic `deploy.sh` that can be used to deploy the project to azure by creating your own `deploy.<env>.sh` file.  The simplest thing to do is to copy the `deploy.sh` to a new file based on the environment you are working with, so something like `deploy.sandbox.sh` and then replace all the values that are enclosed in `<angle-brackets>`.

This script will run the [Bicep modules](https://github.com/anotherRedbeard/dotnet-azfunc-demo/blob/main/iac/bicep) needed to create all the required resources to run this example and it will deploy the code to azure using the `azure functionapp publish` cli command.  It supports three options: all, infra, and function.

```sh
./deploy.sh all|infra|function
```

- `all`: Deploys both the infrastructure and the function.
- `infra`: Deploys only the infrastructure.
- `function`: Deploys only the function.

### Configuration

- `host.json`: Contains the configuration for the Azure Function host.
- `local.settings.json`: Contains local settings for the Azure Functions project.
  - Here is an example `local.settings.json` file that you can use since it is in the `.gitignore` file so it won't be included. The `A72151b_STORAGE` connection is for the queue and blob trigger portion of the code.
  
    ```json
    {
        "IsEncrypted": false,
        "Values": {
            "AzureWebJobsStorage": "UseDevelopmentStorage=true",
            "FUNCTIONS_WORKER_RUNTIME": "java"
        }
    }
    ```

### Queue Triggered Function

This is the default queue based trigger that will just output some log information when it receives the message.

### License

This project is licensed under the MIT License. See the `LICENSE` file for details.
