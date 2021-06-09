---
description: Here's an overview of dynamic volume provisioning - this is how CAST AI allows storage volumes to be created on-demand.
---

# Dynamic volume provisioning

Dynamic volume provisioning allows storage volumes to be created on-demand.
Without dynamic provisioning, cluster administrators have to create new storage volumes manually (using cloud or storage
providers) and the corresponding `PersistentVolume` objects for the storage to be available in Kubernetes.

Dynamic volume provisioning is enabled by default on the CAST AI cluster.

## Overview

Each CAST AI cluster is pre-configured with the default `StorageClass` that handles volume requests.

```shell
» kubectl get sc
NAME                           PROVISIONER           RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
cast-block-storage (default)   storage.csi.cast.ai   Delete          WaitForFirstConsumer   true                   2m18s
```

The binding mode `WaitForFirstConsumer` will delay the binding and provisioning of a `PersistentVolume` until a Pod
using the PVC is created. Meaning, the volume will be created and attached to the Node on which a Pod using the PVC will
be run.

In the case of a Pod replicated across multiple clouds, volumes will be distributed across clouds as well.
This will limit Pod scheduling only to the nodes of the same cloud since to reschedule a Pod to a different cloud
service, the volume must be replicated to that cloud.

!!! tip ""
    This limitation will be removed by the cross-cloud volume replication feature which is not available at the moment.

Deleting a cluster will delete all the volumes that were provisioned dynamically.

## Using dynamic volumes

### Creating persitent volume claim (PVC)

Users can request dynamically provisioned storage by simply creating `PersistentVolumeClaim` and a `Pod` that will
use it.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi

```

Pod example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app
      image: centos
      command: ["/bin/sh"]
      args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
      volumeMounts:
        - name: persistent-storage
          mountPath: /data
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: example-claim
```

This claim results in a Persistent Disk being automatically provisioned. When the claim is deleted, the volume is
deleted as well.

### Volume claim templates

Additionally, having `StatefulSet` user can define `volumeClaimTemplates` to provision volumes without creating PVC
beforehand.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx"
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

This will result in dynamic PVC for each `StatefulSet` pod.

```shell
» kubectl get pvc
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
www-web-0       Bound    pvc-3b550fd0-4b79-449d-b1cf-f51264f975fc   1Gi        RWO            cast-block-storage   3m11s
www-web-1       Bound    pvc-0c7470a8-cc59-49d4-b2ca-5d3db45c1b60   1Gi        RWO            cast-block-storage   2m41s
www-web-2       Bound    pvc-70c341cc-fa1c-471a-882a-e46225e1824f   1Gi        RWO            cast-block-storage   2m18s
```

Deleting a `StatefulSet` will delete all provisioned volumes.

### Resizing PVC

Any PVC created using `cast-block-storage` `StorageClass` can be edited to request more space.
Kubernetes will interpret a change to the storage field as a request for more space. This will trigger automatic volume
resizing.

```shell
» kubectl edit pvc www-web-0
```

Change storage field as shown below:

```yaml
# www-web-0...
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi # new storage size
  storageClassName: cast-block-storage
# www-web-0...
```

After storage is resized successfully, we can observe new PVC capacity:

```shell
k get pvc www-web-0
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
www-web-0   Bound    pvc-edd59e56-cb22-41b6-a075-ab8820f222b8   10Gi       RWO            cast-block-storage   4m57s
```
