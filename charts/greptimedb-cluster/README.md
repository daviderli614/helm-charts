# greptimedb-cluster

A Helm chart for deploying GreptimeDB cluster in Kubernetes.

![Version: 0.1.32](https://img.shields.io/badge/Version-0.1.32-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.8.2](https://img.shields.io/badge/AppVersion-0.8.2-informational?style=flat-square)

## Source Code

- https://github.com/GreptimeTeam/greptimedb

## How to install

### Prerequisites

1. Install the [greptimedb-operator](../greptimedb-operator/README.md);

2. Install the etcd cluster:

   ```console
   helm upgrade \
    --install etcd oci://registry-1.docker.io/bitnamicharts/etcd \
    --set replicaCount=3 \
    --set auth.rbac.create=false \
    --set auth.rbac.token.enabled=false \
    --create-namespace \
    -n etcd-cluster
   ```

### Default installation

The default installation will use the local storage:

```console
helm upgrade \
  --install mycluster \
  --set meta.etcdEndpoints=etcd.etcd-cluster.svc.cluster.local:2379 \
  greptime/greptimedb-cluster \
  -n default
```

### Use AWS S3 as backend storage

Before installation, you must create the AWS S3 bucket, and the cluster will use the bucket as backend storage:

```console
helm upgrade \
  --install mycluster \
  --set meta.etcdEndpoints=etcd.etcd-cluster.svc.cluster.local:2379 \
  --set objectStorage.s3.bucket="your-bucket" \
  --set objectStorage.s3.region="region-of-bucket" \
  --set objectStorage.s3.root="root-directory-of-data" \
  --set objectStorage.credentials.accessKeyId="your-access-key-id" \
  --set objectStorage.credentials.secretAccessKey="your-secret-access-key" \
  greptime/greptimedb-cluster \
  -n default
```

If you set `storage.s3.root` as `mycluser`, then the data layout will be:

```
<your-bucket>
├── mycluser
│   ├── data/
```

## How to uninstall

```console
helm uninstall mycluster -n default
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| base.podTemplate | object | `{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"resources":{"limits":{},"requests":{}}},"nodeSelector":{},"serviceAccountName":"","tolerations":[]}` | The pod template for base |
| base.podTemplate.affinity | object | `{}` | The pod affinity |
| base.podTemplate.annotations | object | `{}` | The annotations to be created to the pod. |
| base.podTemplate.labels | object | `{}` | The labels to be created to the pod. |
| base.podTemplate.main | object | `{"args":[],"command":[],"env":[],"resources":{"limits":{},"requests":{}}}` | The base spec of main container |
| base.podTemplate.main.args | list | `[]` | The arguments to be passed to the command |
| base.podTemplate.main.command | list | `[]` | The command to be executed in the container |
| base.podTemplate.main.env | list | `[]` | The environment variables for the container |
| base.podTemplate.main.resources.limits | object | `{}` | The resources limits for the container |
| base.podTemplate.main.resources.requests | object | `{}` | The requested resources for the container |
| base.podTemplate.nodeSelector | object | `{}` | The pod node selector |
| base.podTemplate.serviceAccountName | string | `""` | The global service account |
| base.podTemplate.tolerations | list | `[]` | The pod tolerations |
| datanode | object | `{"config":"","podTemplate":{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]},"nodeSelector":{},"serviceAccount":{"annotations":{},"create":false},"tolerations":[],"volumes":[]},"replicas":3,"storage":{"dataHome":"/data/greptimedb","storageClassName":null,"storageRetainPolicy":"Retain","storageSize":"10Gi","walDir":"/data/greptimedb/wal"}}` | Datanode configure |
| datanode.config | string | `""` | Extra datanode config in toml format. |
| datanode.podTemplate | object | `{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]},"nodeSelector":{},"serviceAccount":{"annotations":{},"create":false},"tolerations":[],"volumes":[]}` | The pod template for datanode |
| datanode.podTemplate.affinity | object | `{}` | The pod affinity |
| datanode.podTemplate.annotations | object | `{}` | The annotations to be created to the pod. |
| datanode.podTemplate.labels | object | `{}` | The labels to be created to the pod. |
| datanode.podTemplate.main | object | `{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]}` | The spec of main container |
| datanode.podTemplate.main.args | list | `[]` | The arguments to be passed to the command |
| datanode.podTemplate.main.command | list | `[]` | The command to be executed in the container |
| datanode.podTemplate.main.env | list | `[]` | The environment variables for the container |
| datanode.podTemplate.main.image | string | `""` | The datanode image. |
| datanode.podTemplate.main.resources.limits | object | `{}` | The resources limits for the container |
| datanode.podTemplate.main.resources.requests | object | `{}` | The requested resources for the container |
| datanode.podTemplate.main.volumeMounts | list | `[]` | The pod volumeMounts |
| datanode.podTemplate.nodeSelector | object | `{}` | The pod node selector |
| datanode.podTemplate.serviceAccount.annotations | object | `{}` | The annotations for datanode serviceaccount |
| datanode.podTemplate.serviceAccount.create | bool | `false` | Create a service account |
| datanode.podTemplate.tolerations | list | `[]` | The pod tolerations |
| datanode.podTemplate.volumes | list | `[]` | The pod volumes |
| datanode.replicas | int | `3` | Datanode replicas |
| datanode.storage.dataHome | string | `"/data/greptimedb"` | The dataHome directory, default is "/data/greptimedb/" |
| datanode.storage.storageClassName | string | `nil` | Storage class for datanode persistent volume |
| datanode.storage.storageRetainPolicy | string | `"Retain"` | Storage retain policy for datanode persistent volume |
| datanode.storage.storageSize | string | `"10Gi"` | Storage size for datanode persistent volume |
| datanode.storage.walDir | string | `"/data/greptimedb/wal"` | The wal directory of the storage, default is "/data/greptimedb/wal" |
| frontend | object | `{"config":"","podTemplate":{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]},"nodeSelector":{},"serviceAccount":{"annotations":{},"create":false},"tolerations":[],"volumes":[]},"replicas":1,"service":{},"tls":{}}` | Frontend configure |
| frontend.config | string | `""` | Extra frontend config in toml format. |
| frontend.podTemplate | object | `{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]},"nodeSelector":{},"serviceAccount":{"annotations":{},"create":false},"tolerations":[],"volumes":[]}` | The pod template for frontend |
| frontend.podTemplate.affinity | object | `{}` | The pod affinity |
| frontend.podTemplate.annotations | object | `{}` | The annotations to be created to the pod. |
| frontend.podTemplate.labels | object | `{}` | The labels to be created to the pod. |
| frontend.podTemplate.main | object | `{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]}` | The spec of main container |
| frontend.podTemplate.main.args | list | `[]` | The arguments to be passed to the command |
| frontend.podTemplate.main.command | list | `[]` | The command to be executed in the container |
| frontend.podTemplate.main.env | list | `[]` | The environment variables for the container |
| frontend.podTemplate.main.image | string | `""` | The frontend image. |
| frontend.podTemplate.main.resources.limits | object | `{}` | The resources limits for the container |
| frontend.podTemplate.main.resources.requests | object | `{}` | The requested resources for the container |
| frontend.podTemplate.main.volumeMounts | list | `[]` | The pod volumeMounts |
| frontend.podTemplate.nodeSelector | object | `{}` | The pod node selector |
| frontend.podTemplate.serviceAccount.annotations | object | `{}` | The annotations for frontend serviceaccount |
| frontend.podTemplate.serviceAccount.create | bool | `false` | Create a service account |
| frontend.podTemplate.tolerations | list | `[]` | The pod tolerations |
| frontend.podTemplate.volumes | list | `[]` | The pod volumes |
| frontend.replicas | int | `1` | Frontend replicas |
| frontend.service | object | `{}` | Frontend service |
| frontend.tls | object | `{}` | Frontend tls configure |
| grpcServicePort | int | `4001` | GreptimeDB grpc service port |
| httpServicePort | int | `4000` | GreptimeDB http service port |
| image.pullSecrets | list | `[]` | The image pull secrets |
| image.registry | string | `"docker.io"` | The image registry |
| image.repository | string | `"greptime/greptimedb"` | The image repository |
| image.tag | string | `"v0.8.2"` | The image tag |
| initializer.registry | string | `"docker.io"` | Initializer image registry |
| initializer.repository | string | `"greptime/greptimedb-initializer"` | Initializer image repository |
| initializer.tag | string | `"0.1.0-alpha.25"` | Initializer image tag |
| meta | object | `{"config":"","enableRegionFailover":false,"etcdEndpoints":"etcd.default.svc.cluster.local:2379","podTemplate":{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]},"nodeSelector":{},"serviceAccount":{"annotations":{},"create":false},"tolerations":[],"volumes":[]},"replicas":1,"storeKeyPrefix":""}` | Meta configure |
| meta.config | string | `""` | Extra Meta config in toml format. |
| meta.enableRegionFailover | bool | `false` | Whether to enable region failover |
| meta.etcdEndpoints | string | `"etcd.default.svc.cluster.local:2379"` | Meta etcd endpoints |
| meta.podTemplate | object | `{"affinity":{},"annotations":{},"labels":{},"main":{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]},"nodeSelector":{},"serviceAccount":{"annotations":{},"create":false},"tolerations":[],"volumes":[]}` | The pod template for meta |
| meta.podTemplate.affinity | object | `{}` | The pod affinity |
| meta.podTemplate.annotations | object | `{}` | The annotations to be created to the pod. |
| meta.podTemplate.labels | object | `{}` | The labels to be created to the pod. |
| meta.podTemplate.main | object | `{"args":[],"command":[],"env":[],"image":"","resources":{"limits":{},"requests":{}},"volumeMounts":[]}` | The spec of main container |
| meta.podTemplate.main.args | list | `[]` | The arguments to be passed to the command |
| meta.podTemplate.main.command | list | `[]` | The command to be executed in the container |
| meta.podTemplate.main.env | list | `[]` | The environment variables for the container |
| meta.podTemplate.main.image | string | `""` | The meta image. |
| meta.podTemplate.main.resources.limits | object | `{}` | The resources limits for the container |
| meta.podTemplate.main.resources.requests | object | `{}` | The requested resources for the container |
| meta.podTemplate.main.volumeMounts | list | `[]` | The pod volumeMounts |
| meta.podTemplate.nodeSelector | object | `{}` | The pod node selector |
| meta.podTemplate.serviceAccount.annotations | object | `{}` | The annotations for meta serviceaccount |
| meta.podTemplate.serviceAccount.create | bool | `false` | Create a service account |
| meta.podTemplate.tolerations | list | `[]` | The pod tolerations |
| meta.podTemplate.volumes | list | `[]` | The pod volumes |
| meta.replicas | int | `1` | Meta replicas |
| meta.storeKeyPrefix | string | `""` | Meta will store data with this key prefix |
| mysqlServicePort | int | `4002` | GreptimeDB mysql service port |
| objectStorage | object | `{"oss":{},"s3":{}}` | Configure to object storage |
| postgresServicePort | int | `4003` | GreptimeDB postgres service port |
| prometheusMonitor | object | `{"enabled":false,"interval":"30s","labels":{"release":"prometheus"}}` | Configure to prometheus PodMonitor |
| prometheusMonitor.enabled | bool | `false` | Create PodMonitor resource for scraping metrics using PrometheusOperator |
| prometheusMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped |
| prometheusMonitor.labels | object | `{"release":"prometheus"}` | Add labels to the PodMonitor |
