##############
# VARIABLES:-
############## 
$spiname = "AM-Test-SPI-200"
$rbac = "Contributor"
$pat = "<Provide your own PAT>"
$devopsOrg = "https://dev.azure.com/arindammitra0251/"
$devopsPrj = "AMCLOUD"
$subsID = "210e66cb-55cf-424e-8daa-6cad804ab604"
$subsName = "AM-PROD-VS"
$tenantID = "20516b3d-42af-4bd4-b2e6-e6b4051af72a"
$kv = "ampockv"

##############
# CORE SCRIPT:-
############## 

# Create Service Principal and Store Secret in a variable:-
$spipasswd = az ad sp create-for-rbac -n $spiname --query "password" -o tsv

# Query the Application ID of the Service Principal and Store it in a variable:-
$spiID = az ad sp list --display-name $spiname --query [].appId -o tsv

# Store the Service Principal Application ID and Secret in Key Vault:-
az keyvault secret set --name $spiname-id --vault-name $kv --value $spiID
az keyvault secret set --name $spiname-passwd --vault-name $kv --value $spipasswd

# Assign the Service Principal, "Contributor" RBAC on Subscription Level:-
az role assignment create --assignee "$spiID" --role "$rbac" --scope "/subscriptions/$subsID"

# Set Service Principal Secret as an Environment Variable for creating Azure DevOps Service Connection:-
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$spipasswd

# Set PAT as an environment variable for DevOps Login:-
$env:AZURE_DEVOPS_EXT_PAT = $pat

# Set Default DevOps Organisation and Project:-
az devops configure --defaults organization=$devopsOrg project=$devopsPrj

# Create DevOps Service Connection:-
az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $subsID --azure-rm-subscription-name $subsName --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsPrj

# Grant Access to all Pipelines to the Newly Created DevOps Service Connection:-
$srvEndpointID = az devops service-endpoint list --query "[?name=='$spiname'].id" -o tsv
az devops service-endpoint update --id $srvEndpointID --enable-for-all



