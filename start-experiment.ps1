param
(
    $namePrefix,
    $storageType,
    $sizeInGiB,
    $machineSize,
    $testType
)

function SetWorkspace($workspaceName)
{
    if ((terraform workspace list) | Where-Object { $_ -match "[^ \*]*$workspaceName" }) 
    { 
        terraform workspace select $workspaceName 
    } 
    else 
    { 
        terraform workspace new $workspaceName 
    }
}

function GetExperimentName($machineSize, $testType, $storageType, $sizeInGiB)
{
    $vmSizeShort = [Regex]::Match($machineSize, "[^_]+_(?<size>.+)").Groups["size"].Value.Replace("_","").Replace("-","")
    $storageTypeShort = $storageType.substring(0,2)
    $testTypeShort = $testType.substring(0,1)
    return "$vmSizeShort$storageTypeShort$sizeInGiB$testTypeShort".ToLower()
}

function FailOnNonZeroExitCode($errorMessage = $null)
{
    if ($LASTEXITCODE -ne 0)
    {
        if ($errorMessage)
        {
            throw $errorMessage
        }

        throw "CLI failed with exit code $LASTEXITCODE"
    }
}

# Init
$experimentName = GetExperimentName -machineSize $machineSize -testType $testType -storageType $storageType -sizeInGiB $sizeInGiB
$storageContainerName = $experimentName

# Create Resources
Push-Location
Set-Location -Path $PSScriptRoot\tf
terraform init
SetWorkspace -workspaceName "$namePrefix.$experimentName"
FailOnNonZeroExitCode
terraform apply -auto-approve -var name_prefix=$namePrefix -var machine_size=$machineSize -var default_node_pool_name=$experimentName -var nfs_container_name=$storageContainerName
FailOnNonZeroExitCode
$terraformOutput = (terraform output -json) | ConvertFrom-Json
FailOnNonZeroExitCode
Pop-Location

$clusterName = $terraformOutput.cluster_name.value
$clusterRgName = $terraformOutput.cluster_resource_group_name.value
$storageAccountName = $terraformOutput.storage_account_name.value
$storageAccountResourceGroupName = $terraformOutput.storage_account_resource_group_name.value

# Prepare Storage
# Because of https://github.com/hashicorp/terraform-provider-azurerm/issues/2977, we need to create the container in script for now (instead of doing it in tf)
az storage account network-rule add --account-name cadstrgtst02stor --ip-address "$((Invoke-WebRequest https://ipinfo.io/ip).Content)"
az storage container create -n $storageContainerName --account-name $storageAccountName  
# TODO: Import data to read for the experiment into the storage account

az aks get-credentials --resource-group $clusterRgName --name $clusterName
FailOnNonZeroExitCode

# Install blob driver
helm repo add blob-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/charts
FailOnNonZeroExitCode
helm repo update
FailOnNonZeroExitCode
helm upgrade --install blob-csi-driver blob-csi-driver/blob-csi-driver --namespace kube-system
FailOnNonZeroExitCode

Push-Location
Set-Location -Path $PSScriptRoot\helm
helm upgrade --install $experimentName . --set "storage.storageAccountName=$storageAccountName" --set "storage.storageAccountResourceGroupName=$storageAccountResourceGroupName" --set "storage.size=$($sizeInGiB)Gi" --set "storage.type=$storageType" --set "storage.containerName=$storageContainerName"
FailOnNonZeroExitCode
Pop-Location