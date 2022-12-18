# CREATE SERVICE CONNECTION USING DEVOPS CLI

Greetings to my fellow Technology Advocates and Specialists.

In this Session, I will demonstrate __How to Create Service Connection Using DevOps CLI.__

I had the Privilege to talk on this topic in __ONE__ Azure Communities:-

| __NAME OF THE AZURE COMMUNITY__ | __TYPE OF SPEAKER SESSION__ |
| --------- | --------- |
| __Festive Tech Calendar 2022__ | __Virtual__ |


| __LIVE RECORDED SESSION:-__ |
| --------- |
| __LIVE DEMO__ was Recorded as part of my Presentation in __FESTIVE TECH CALENDAR 2022__ Forum/Platform |
| Duration of My Demo = __1 Hour 05 Mins 08 Secs__ |
| [![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/pcIVKO2dlEI/0.jpg)](https://www.youtube.com/watch?v=pcIVKO2dlEI&t=80s) |


| __USE CASES:-__ |
| --------- |
| Create DevOps Service Connection, __Prompting PAT__ (Personal Access Token) |
| Create DevOps Service Connection, __Without Prompting PAT__ (Personal Access Token) |


| __AUTOMATION OBJECTIVE:-__ |
| --------- |
| Create __Service Principal__. |
| __Query the Application ID__ of the Service Principal. |
| __Store__ the Service Principal Application ID and Secret in __Key Vault__. |
| Assign the Service Principal, __"Contributor" RBAC__ (Role Based Access Control) on Subscription Level. |
| Set __Service Principal Secret as an Environmental Variable__ for creating Azure DevOps Service Connection. |
| Set __PAT (Personal Access Token) as an environment variable__ for DevOps Login. |
| Create __Azure DevOps Service Connection__. |
| __Grant Access to all Pipelines__ to the Newly Created Azure DevOps Service Connection. |
| __Verify__ Service Connection. |


| __REQUIREMENTS:-__ |
| --------- |

1. Azure Subscription.
2. Azure DevOps Organisation and Project.
3. Full Access PAT (Personal Access Token).
4. The Identity executing the script has required privilege to a) Create Service Principal in Azure Active Directory, b) Assign RBAC, and c) Create Secret in Key vault.


| __CODE REPOSITORY:-__ |
| --------- |
| {% github arindam0310018/15-Nov-2022-DevOpsCLI__Create-Service-Connection %} |


| BELOW FOLLOWS THE CODE SNIPPET:- | 
| --------- |

| USE CASE #1:- | 
| --------- |

| CREATE AZURE DEVOPS SERVICE CONNECTION WITH PAT AS USER INPUT (Create-DevOps-Service-Connection-Prompt-PAT.ps1):- | 
| --------- |

```
##############
# VARIABLES:-
############## 
$spiname = "AM-Test-SPI-100"
$rbac = "Contributor"
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

#Set Service Principal Secret as an Environment Variable for creating Azure DevOps Service Connection:-
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$spipasswd

# Perform DevOps Login. It will Prompt for PAT:-
az devops login

# Set Default DevOps Organisation and Project:-
az devops configure --defaults organization=$devopsOrg project=$devopsPrj

# Create DevOps Service Connection:-
az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $subsID --azure-rm-subscription-name $subsName --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsPrj

# Grant Access to all Pipelines to the Newly Created DevOps Service Connection:-
$srvEndpointID = az devops service-endpoint list --query "[?name=='$spiname'].id" -o tsv
az devops service-endpoint update --id $srvEndpointID --enable-for-all

```

| USE CASE #2:- | 
| --------- |

| CREATE AZURE DEVOPS SERVICE CONNECTION WITH PAT AS ENVIRONMENT VARIABLE (Create-DevOps-Service-Connection-Without-Prompting-PAT.ps1):- | 
| --------- |

```
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

#Set Service Principal Secret as an Environment Variable for creating Azure DevOps Service Connection:-
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

```

| __DIFFERENCE BETWEEN BOTH USE CASES:-__ | 
| --------- |
| In Use Case 1, PAT is prompted as User Input during script execution. |
| In Use Case 2, PAT is set as Environment variable so that it is not prompted as User Input during script execution. |


__Now, let me explain the script, part by part for better understanding.__

| __VARIABLES:-__ | 
| --------- |

__USE CASE 1:-__

```
##############
# VARIABLES:-
############## 
$spiname = "AM-Test-SPI-100"
$rbac = "Contributor"
$devopsOrg = "https://dev.azure.com/arindammitra0251/"
$devopsPrj = "AMCLOUD"
$subsID = "210e66cb-55cf-424e-8daa-6cad804ab604"
$subsName = "AM-PROD-VS"
$tenantID = "20516b3d-42af-4bd4-b2e6-e6b4051af72a"
$kv = "ampockv"

```

__USE CASE 2:-__

```
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

```

| __NOTE:-__ | 
| --------- |
| Please change the values of the variables accordingly. |
| The entire script is build using __Variables__. No Values are Hardcoded. Changing the values of the variables should help you execute the script seamlessly. |


| __CORE SCRIPT:-__ | 
| --------- |

__Create Service Principal and Store Secret in a variable:-__

```
$spipasswd = az ad sp create-for-rbac -n $spiname --query "password" -o tsv
```

__Query the Application ID of the Service Principal and Store it in a variable:-__

```
$spiID = az ad sp list --display-name $spiname --query [].appId -o tsv
```

__Store the Service Principal Application ID and Secret in Key Vault:-__

```
az keyvault secret set --name $spiname-id --vault-name $kv --value $spiID
az keyvault secret set --name $spiname-passwd --vault-name $kv --value $spipasswd
```

__Assign the Service Principal, "Contributor" RBAC on Subscription Level:-__

```
az role assignment create --assignee "$spiID" --role "$rbac" --scope "/subscriptions/$subsID"
```

__Set Service Principal Secret as an Environment Variable for creating Azure DevOps Service Connection:-__

```
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$spipasswd
```

__Perform DevOps Login. It will Prompt for PAT Token:-__

```
az devops login
```

OR

__Set PAT as an environment variable for DevOps Login:-__

```
$env:AZURE_DEVOPS_EXT_PAT = $pat
```

__Set Default DevOps Organisation and Project:-__

```
az devops configure --defaults organization=$devopsOrg project=$devopsPrj
```

__Create DevOps Service Connection:-__

```
az devops service-endpoint azurerm create --azure-rm-service-principal-id $spiID --azure-rm-subscription-id $subsID --azure-rm-subscription-name $subsName --azure-rm-tenant-id $tenantID --name $spiname --org $devopsOrg --project $devopsPrj
```

__Grant Access to all Pipelines to the Newly Created DevOps Service Connection:-__

```
$srvEndpointID = az devops service-endpoint list --query "[?name=='$spiname'].id" -o tsv
az devops service-endpoint update --id $srvEndpointID --enable-for-all
```

__NOW ITS TIME TO TEST__

| __TEST CASES:-__ | 
| --------- |

| __TEST CASE FOR USE CASE #1: PAT AS USER INPUT:-__ | 
| --------- |
| Service Principal has been created. Application ID and Secret has been Stored in Key Vault. __"Contributor"__ RBAC has been assigned to the newly created Service Principal on Subscription Level. |
| As Observed, the script is now waiting for User Input PAT. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ekcrni3ztlgxn2nqifzr.png) |
| After providing the correct PAT, script executed successfully. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0pogzmrpxx1vn5zyiyjv.png) |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wblmqcfb4fe2slaia2tn.png) |
| Service Principal (with secret) created successfully. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rwbtnsf3hofybe9mj22u.jpg) |
| Application ID and Secret of Service Principal has been stored in Key Vault. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/h10lpp77yxkzd4qyzadh.jpg) |
| __"Contributor"__ RBAC has been assigned to the newly created Service Principal on Subscription Level.|
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/snk79lq7rgn0gpv4yctk.jpg) |
| Azure DevOps Service Connection has been created successfully with the newly created Service Principal. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/g3czfmdplluk47sn72dt.jpg) |
| Azure DevOps Service Connection Verification is successful. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qy4r5o2sjoiz7jrj27t5.jpg) |

| __TEST CASE FOR USE CASE #2: PAT AS ENVIRONMENT VARIABLE:-__ | 
| --------- |
| Service Principal has been created. Application ID and Secret has been Stored in Key Vault. __"Contributor"__ RBAC has been assigned to the newly created Service Principal on Subscription Level. |
| As Observed, __No PAT is prompted during script execution.__ |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/sjzjwytbly8azp211znx.png) |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ka276pbmbyy8ryezg684.png) |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/8ifhuvuo18194e7xmd9i.png) |
| Service Principal (with secret) created successfully. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t7466x8vcs02c6cymelz.jpg) |
| Application ID and Secret of Service Principal has been stored in Key Vault. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/19ksgdb0zfirsslsg7md.jpg) |
| __"Contributor"__ RBAC has been assigned to the newly created Service Principal on Subscription Level.|
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ygc76sp0l387ruavye56.jpg) |
| Azure DevOps Service Connection has been created successfully with the newly created Service Principal. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/mrxyb4kqb0lh89nirwbz.jpg) |
| Azure DevOps Service Connection Verification is successful. |
| ![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qffmdn77e42em1zs6adi.jpg) |


__Hope You Enjoyed the Session!!!__

__Stay Safe | Keep Learning | Spread Knowledge__
