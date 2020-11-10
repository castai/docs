# Horizontal Pod Autoscaler

## Scaling an application

There are two ways to scale an application: 
* Vertically: add more resources (RAM/CPU/Disk IOPS) to the same instance
* Horizontally: add more instances (replicas) of the same application

The problem with vertical scaling is that you'll either find out that enough hardware (RAM, CPU, Disk IOPS) in a single machine cost too much, or the cloud provider cannot provision a machine with enough resources. Horizontal scaling strategy avoids such limitations.

## Horizontal scaling strategy

As mentioned above, horizontal scaling strategy involves adding (or removing) additional replicas of the same application. The problem is, that most applications' load patterns can have spikes which are not predictable which renders manual scaling nearly impossible. Luckily, we can automate this process!

## The HPA & KEDA

Kubernetes comes equipped with [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) functionality. It can scale up (add more replicas) or down (remove idling replicas) based on some metrics. The problem is that HPA, by default, comes without batteries: it doesn't have the metrics source. We're lucky again: CAST AI bundles the batteries for you! We've got you covered by providing [KEDA](https://keda.sh) addon.

### How does it work?

KEDA consists of two components: 

- **operator** -- watches k8s for ScaledObject resources and configures HPA accordingly
- **metrics-apiserver** -- a bridge between Kubernetes and various scaling sources (including Prometheus)

These components do the heavy lifting of configuring Kubernetes HPA and setting up the custom metric sources. This enables us to autoscale almost any workload: `Deployment`, `ReplicaSet`, `ReplicationController`, or `StatefulSet`. KEDA does support autoscaling Jobs as well.

### Enabling KEDA

In order to take advantage of autoscaling functionality, you must enable KEDA addon in the `Policies` page: 

1. Navigate to an existing cluster (in case you don't have one already, go a head and [create one](../../getting-started/creating-your-first-cluster.md))

1. On the left navigation menu, select `Policies`:
![Navigate to policies](010_navigate.png)

1. Enable Horizontal pod autoscaler
![Enable](020_enable.png)

## Examples

### Autoscale Based on CPU and/or Memory usage

Let's create a `Deployment` and a `Service` which we will **Autoscale**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  # Note that we omit the replica count so 
  # when we redeploy, we wouldn't override 
  # replica count set by the autoscaler
  #replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - image: luxas/autoscale-demo:v0.1.2
        name: sample-app
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  ports:
  - port: 8080
    name: http
    targetPort: 8080
    protocol: TCP
  selector:
    app: sample-app
```

**Note**: we don't specify the ReplicaCount ourselves

Now let us set up a [CPU-based Autoscaler](https://keda.sh/docs/2.0/scalers/cpu/)

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: sample-app
spec:
  scaleTargetRef:
    name:          sample-app
  minReplicaCount: 1        # Optional. Default: 0
  maxReplicaCount: 10       # Optional. Default: 100
  triggers:
    # Either of the triggers can be omitted.
    - type: cpu
      metadata:
        # Possible values: `Value`, `Utilization`, or `AverageValue`.
        # More info at: https://keda.sh/docs/2.0/scalers/cpu/#trigger-specification
        type: "Value" 
        value: "30"
    - type: memory
      metadata:
        # Possible values: `Value`, `Utilization`, or `AverageValue`.
        # More info at: https://keda.sh/docs/2.0/scalers/memory/
        type: "Value" 
        value: "512"    
```

Now our Deployment autoscaling will be triggered either by CPU or Memory usage. We could any other trigger, or remove
either of those if we so desire (i.e. to autoscale only on **CPU** basis, remove the **Memory** trigger, and vice-versa).

### Autoscale based on Prometheus metric

It is possible to autoscale based on result of arbitrary Prometheus query. What is more, CAST AI k8s clusters comes with
Prometheus deployed out of the box!

Let's deploy the sample app again, but this time, let's instruct Prometheus to scrape metrics:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
      annotations:
        # These annotations the main difference!
        prometheus.io/path: "/metrics"
        prometheus.io/port: "8080"
        prometheus.io/scrape: "true"
    spec:
      containers:
      - image: luxas/autoscale-demo:v0.1.2
        name: sample-app
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  ports:
  - port: 8080
    name: http
    targetPort: 8080
    protocol: TCP
  selector:
    app: sample-app
```

Now let's deploy the Autoscaler!
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: sample-app
spec:
  scaleTargetRef:
    name:          sample-app
  minReplicaCount: 1        # Optional. Default: 0
  maxReplicaCount: 10       # Optional. Default: 100
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prom.castai:9090
        metricName: http_requests_total_sample_app
        threshold: '1'
        # Note: query must return a vector/scalar single element response
        query: sum(rate(http_requests_total{app="sample-app"}[2m]))
```

Now let's generate some load and observe that replica count is increased:
```shell script
# Deploy busybox image
kubectl run -it --rm load-generator --image=busybox /bin/sh

# Hit ENTER for command prompt

# trigger infinite requests to the php-apache server
while true; do wget -q -O- http://sample-app:8080/metrics; done

# in order to cancel, hold CTRL+C
# in order to quit, initiate CTRL+D sequence
```

## Troubleshooting

Verify that KEDA is scheduled and running (the suffixes might be different):
```shell script
$ kubectl get pods -n keda
NAME                                      READY   STATUS    RESTARTS   AGE
keda-metrics-apiserver-59679c9f96-5lfr5   1/1     Running   0          74m
keda-operator-66744fc69d-7njdd            1/1     Running   0          74m
```

Describe ScaledObject for clues. In this case, scaledObjectRef points to nonexistent object:
```shell script
$ kubectl describe scaledobjects.keda.sh sample-app 
Name:         sample-app
Namespace:    default
Labels:       scaledObjectName=sample-app
Annotations:  API Version:  keda.sh/v1alpha1
Kind:         ScaledObject
Metadata:
  Creation Timestamp:  2020-11-10T10:12:38Z
  Finalizers:
    finalizer.keda.sh
  Generation:  1
  Managed Fields:
    <... snip ...>
  Resource Version:  394466
  Self Link:         /apis/keda.sh/v1alpha1/namespaces/default/scaledobjects/sample-app
  UID:               9394d57a-ae66-4e80-baf4-8d6bb7fd36f9
Spec:
  Advanced:
    Horizontal Pod Autoscaler Config:
      Behavior:
        Scale Down:
          Policies:
            Period Seconds:              15
            Type:                        Percent
            Value:                       100
          Stabilization Window Seconds:  300
    Restore To Original Replica Count:   true
  Cooldown Period:                       300
  Max Replica Count:                     10
  Min Replica Count:                     1
  Polling Interval:                      30
  Scale Target Ref:
    API Version:  apps/v1
    Kind:         Deployment
    Name:         sample-app
  Triggers:
    Metadata:
      Metric Name:     http_requests_total
      Query:           sum(rate(http_requests_total{app="sample-app"}[2m]))
      Server Address:  http://prom.castai:9090
      Threshold:       1
    Type:              prometheus
Status:
  Conditions:
    Message:  ScaledObject doesn't have correct scaleTargetRef specification
    Reason:   ScaledObjectCheckFailed
    Status:   False                                       <--------- This means that this check didn't pass
    Type:     Ready
    Message:  ScaledObject check failed
    Reason:   UnkownState
    Status:   Unknown
    Type:     Active
Events:       <none>
```

Inspect KEDA operator logs:
```shell script
kubectl logs -n keda $(kubectl get pods -n keda -o name | grep operator)
```

