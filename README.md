# TODO

- immer nur eine kombi zur selben zeit testen
- parameter für jeden run:
  - disk/file/blob? 
  - Storage-Größe in GiB?
  - Machine-Size
  - read or write-test?
- entweder schreib- oder lese-test
- alle storage-optionen vorbereiten
- namen des node pools setzen, um test in logs identifizierbar zu machen
- log analytics workspace dauerhaft macehn, um test logs über einzelnen test hinaus zu haben
- alle rechte setzen
- fürs schreiben:
  - wie gehabt
- fürs lesen:
  - kleinteiliges repo in den storage account kopieren
  - das komplett durchiterieren

TODO vNext:
- Ultra-Disk mit aufnehmen?


# CSI Stuff for using blob storage with NFSv3
Even if the default csi drivers (storage providers `disk.csi.azure.com` and `file.csi.azure.com`) are already installed (you can easily check on your cluster with `kubectl get csidriver`), we still need to install the blob csi driver, like this (from the [docs](helm repo add blob-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/charts
helm install blob-csi-driver blob-csi-driver/blob-csi-driver --namespace kube-system
)):

```sh
   helm repo add blob-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/charts
   helm install blob-csi-driver blob-csi-driver/blob-csi-driver --namespace kube-system
```

The driver source code is located on [GitHub](https://github.com/kubernetes-sigs/blob-csi-driver).

Parameter settings are documented [here](https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md).

# TODO

* offer custom metrics in pod via prometheus /metrics endpoint like how many tests have already run

# stressiotest 

Simple Helm Chart and script to compare the IO performance of different node size and storage class settings.

With Azure monitor this can result in metrics like this:

![Azure Monitor showing IOPs and Write Bytes/s for four different combinations of VM size, disk size, storage class](./media/MetricsDashboard.png)