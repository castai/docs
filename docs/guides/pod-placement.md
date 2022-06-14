---
description: Take a look at this guide to learn how to place pods using labels and Kubernetes scheduling features
---

# Configure pod placement by topology

This guide will show how to place pods in particular node, zone, region, cloud, etc., using labels and advanced Kubernetes scheduling features. Kubernetes supports this by using:

- [`Node selector`](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)
- [`Node affinity and anti-affinity`](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
- [`Topology spread constraints`](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/)

All of these methods require special labels to be present on each Kubernetes node.

## External clusters connected to CAST AI

CAST AI supports the following labels:

| Label | Type| Description | Example(s)                                                                |
| ------------ | ------------- | ------------ |---------------------------------------------------------------------------|
| `kubernetes.io/arch` and `beta.kubernetes.io/arch` | well-known  | Node CPU architecture | `amd64`                                                                   |
| `node.kubernetes.io/instance-type` and `beta.kubernetes.io/instance-type` | well-known  | Node type (cloud-specific) | `t3a.large`, `e2-standard-4`                                              |
| `kubernetes.io/os` and `beta.kubernetes.io/os` | well-known  | Node Operating System | `linux`                                                                   |
| `kubernetes.io/hostname` | well-known  | Node Hostname | `ip-192-168-32-94.eu-central-1.compute.internal`, `testcluster-31qd-gcp-3ead` |
| `topology.kubernetes.io/region` and `failure-domain.beta.kubernetes.io/region` | well-known | Node region in the CSP | `eu-central-1`, `europe-central1`                                         |
| `topology.kubernetes.io/zone` and `failure-domain.beta.kubernetes.io/zone` | well-known | Node zone of the region in the CSP | `eu-central-1a`,`europe-central1-a`                                       |
| `provisioner.cast.ai/managed-by` | CAST AI specific | CAST AI managed node | `cast.ai`                                                                 |
| `provisioner.cast.ai/node-id` | CAST AI specific | CAST AI node ID| `816d634e-9fd5-4eed-b13d-9319933c9ef0`                                      |
| `scheduling.cast.ai/spot` | CAST AI specific | Node lifecycle type - spot | `true`                                                                      |
| `scheduling.cast.ai/spot-backup` | CAST AI specific | A fallback for spot instance | `true`                                                                    |
| `topology.cast.ai/subnet-id` | CAST AI specific | Node subnet ID | `subnet-006a6d1f18fc5d390`                                                  |
| `scheduling.cast.ai/storage-optimized` | CAST AI specific | Local SSD attached node | `true`                                                                      |
| `scheduling.cast.ai/compute-optimized` | CAST AI specific | A compute optimized instance | `true` |

### Highly-available pod scheduling

Pods can be scheduled in a highly-available fashion by using the topology spread constraints feature. CAST AI supports these fault-domains, i.e. topology keys:

- `topology.kubernetes.io/zone` - enables your pods to be spread between availability zones, taking advantage of cloud redundancy.

!!! note ""
    CAST AI will only create nodes in different fault-domains when the `whenUnstatisfiable` property equals `DoNotSchedule`. The value `ScheduleAnyway` means that the spread is just a preference, so the autoscaler will keep bin-packing those pods, which might result in all of them being scheduled on the same fault-domain.

The deployment described below will be spread and scheduled on all availability zones supported by your cluster:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: az-topology-spread
  name: az-topology-spread
spec:
  replicas: 30
  selector:
    matchLabels:
      app: az-topology-spread
  template:
    metadata:
      labels:
        app: az-topology-spread
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - az-topology-spread
      containers:
        - image: nginx
          name: nginx

```

### Scheduling on nodes with locally attached SSD

The pod described below will be scheduled on a Spot instance with locally attached SSD disk.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demopod
spec:
  nodeSelector:
    scheduling.cast.ai/spot: "true"
    scheduling.cast.ai/storage-optimized: "true"
  tolerations:
    - key: scheduling.cast.ai/spot
      operator: Exists  
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        ephemeral-storage: "2Gi"
      limits:
        ephemeral-storage: "4Gi"
    volumeMounts:
    - name: ephemeral
      mountPath: "/tmp"
  volumes:
    - name: ephemeral
      emptyDir: {}
```

### Scheduling on compute optimized nodes

Compute optimized instances are ideal for compute-bound applications that benefit from high-performance processors.
They offer the highest consistent performance per core to support real-time application performance.

The pod described below will be scheduled on a compute optimized instance.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demopod
spec:
  nodeSelector:
    scheduling.cast.ai/compute-optimized: "true"
  containers:
  - name: app
    image: nginx
```

## CAST AI multi cloud Kubernetes clusters

CAST AI multi cloud Kubernetes cluster nodes are already equipped with the following labels:

| Label | Type| Description | Example(s)|
| ------------ | ------------- | ------------ | ------------ |
| `node.kubernetes.io/instance-type` | well-known  | Node type (cloud-specific) | t3a.large, e2-standard-4 |
| `kubernetes.io/arch` | well-known  | Node CPU architecture | amd64 |
| `kubernetes.io/hostname` | well-known  | Node Hostname | ip-10-10-2-81, testcluster-31qd-gcp-3ead |
| `kubernetes.io/os` | well-known  | Node Operating System | linux |
| `topology.kubernetes.io/region` | well-known | Node region in the CSP | eu-central-1 |
| `topology.kubernetes.io/zone` | well-known | Node zone of the region in the CSP | eu-central-1a |
| `topology.cast.ai/csp` | CAST AI specific | Node Cloud Service Provider | aws, gcp, azure |

### How to pin a pod to AWS

We will use `affinity.nodeAffinity`:

```yaml
affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.cast.ai/csp
                operator: In
                values:
                  - aws
```

Pod example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.storage.csi.cast.ai/csp
                operator: In
                values:
                  - aws
  containers:
    - name: nginx
      image: k8s.gcr.io/nginx-slim:0.8
      ports:
        - containerPort: 80
          name: web
```

StatefulSet example, it will create 3 pods each in every cloud (note the podAntiAffinity):

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: a-web
spec:
  podManagementPolicy: Parallel
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: topology.storage.csi.cast.ai/csp
                    operator: In
                    values:
                      - aws
                      - gcp
                      - azure
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - nginx
              topologyKey: topology.storage.csi.cast.ai/csp
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

### How to a isolate specific workloads

It's a best practice to set workload requests and limits identical and distribute various workloads among all the nodes in the cluster so that Law of Averages
would provide best performance and availability. Having said that, there might be some edge case to isolate volatile workloads to their nodes and not mix them with other workloads in the same clusters. In such scenario we will use `affinity.podAntiAffinity`:

```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: kubernetes.io/hostname
      labelSelector:
        matchExpressions:
        - key: <any POD label>
          operator: DoesNotExist
```

Pod example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worklow-jobs
  labels:
    app: workflows
spec:
  replicas: 2
  selector:
    matchLabels:
      app: workflows
  template:
    metadata:
      labels:
        app: workflows
        no-requests-workflows: "true"
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - topologyKey: kubernetes.io/hostname
            labelSelector:
              matchExpressions:
              - key: no-requests-workflows
                operator: DoesNotExist
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 300m  
```
