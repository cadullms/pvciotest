helm upgrade --install `
    --set "scheduling.nodeSelectorInstanceType=Standard_DS4_v2" `
    --set "pvc.size=256Gi"`
    --set "pvc.storageClass=managed-premium"`
    --set "scheduling.onlyOnePerNode=true" premium256-bigmachine ./helm

helm upgrade --install `
    --set "scheduling.nodeSelectorInstanceType=Standard_DS2_v2" `
    --set "pvc.size=256Gi"`
    --set "pvc.storageClass=managed-premium"`
    --set "scheduling.onlyOnePerNode=true" premium256-smallmachine ./helm

helm upgrade --install `
    --set "scheduling.nodeSelectorInstanceType=Standard_DS2_v2" `
    --set "pvc.size=16Gi"`
    --set "pvc.storageClass=managed-premium"`
    --set "scheduling.onlyOnePerNode=true" premium16-smallmachine ./helm

helm upgrade --install `
    --set "scheduling.nodeSelectorInstanceType=Standard_DS2_v2" `
    --set "pvc.size=2Gi"`
    --set "pvc.storageClass=default"`
    --set "scheduling.onlyOnePerNode=true" default2-smallmachine ./helm
