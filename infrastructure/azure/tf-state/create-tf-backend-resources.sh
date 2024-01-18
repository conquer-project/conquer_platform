#!/bin/bash 
# I dont want terragrunt managing these resources because I need them to keep creating and destroying everything

set -o nounset                              # Treat unset variables as an error

resourceGroupName="rg-tfstate-lowers-001"
storageAccountName="stgtfstatelowers001"
containerName="tf-state"
location="eastus2"

# Create a resource group
if [[ "$(az group list --output json | jq -r --arg rg "$resourceGroupName" '.[] | select(.name == $rg) | .name')" != "$resourceGroupName" ]]; then
    az group create --name "$resourceGroupName" --location "$location"
    az group wait --create --name "$resourceGroupName"
    echo "Resource Group $resourceGroupName created"
else
    echo "RG $resourceGroupName already in place"
fi

# Create a storage account
if [[ ! "$(az storage account list -o json | jq -r --arg stg "$storageAccountName" '.[] | select(.name == $stg) | .name')" ]]; then
    az storage account create --name $storageAccountName --resource-group $resourceGroupName --sku Standard_LRS
    
    while [[ "$(az storage account show --name $storageAccountName --resource-group $resourceGroupName --query "provisioningState" -o tsv)" != "Succeeded" ]]; do
        echo "Waiting for storage account creation to complete..."
        sleep 3 
    done
    echo "Storage Account $storageAccountName created"
else
    echo "Storage Account $storageAccountName already in place"
fi

# Create Storage Container
accountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query "[0].value" --output tsv)

if [[ "$(az storage container list --account-name $storageAccountName --account-key "$accountKey" | jq -r --arg containerName "$containerName" '.[] | select(.name == $containerName) | .name')" != "$containerName" ]]; then
    az storage container create --account-name "$storageAccountName" --account-key "$accountKey" --name "$containerName"
    echo "Storage Container $containerName created"
else
    echo "Storage Container already in place"
fi
printf "\n Azure resources created successfully!"
