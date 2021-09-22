$namePrefix = "cadstrgtst" # replace with your own prefix (needs to be unique in the cloud you are in as it is used for the storage account host name like <namePrefix>stor.blob.core.windows.net/

& $PSScriptRoot/start-experiment.ps1 -namePrefix "${namePrefix}01" -storageType "disk" -sizeInGiB 100 -machineSize "Standard_DS2_v2" -testType "Write"
& $PSScriptRoot/start-experiment.ps1 -namePrefix "${namePrefix}02" -storageType "blob" -sizeInGiB 100 -machineSize "Standard_DS2_v2" -testType "Write"
# todo: different disk size/machine size combinations
# todo: blob
# todo: file

