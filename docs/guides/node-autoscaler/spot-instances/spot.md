# Spot/Preemptible Instances

CAST AI autoscaler supports running your workloads on Spot/Preemtible instances.
In this guide, we will show you just how easy it is to do that.


## Available configurations

### Tolerations

When pod is marked only with Toleration, Kubernetes scheduler could place such pod(s) on regular nodes as well.
This option should be preferred, when spot instances are optional for your workloads.

```yaml
...
tolerations:
  - key: scheduling.cast.ai/spot
    operator: Exists
...
```


### Node Selectors

If you want to make sure that a pod is scheduled on spot instances only, in addition to tolerations, you must add `nodeSelector` as well.
This way autoscaler ensures that whenever your pod requires additional workload in the cluster, only spot instance is picked to satisfy the needs.

```yaml
...
tolerations:
  - key: scheduling.cast.ai/spot
    operator: Exists
nodeSelector:
  scheduling.cast.ai/spot: "true"
...
```

## Step-by-step deployment on Spot Instance

In this step-by-step guide we demonstrate how to use Spot Instances with your CAST AI clusters.

In order to do that, we will be using example NGINX deployment, where it is configured to only be ran on Spot/Preemtible instances.

### 0. Pre-requisites

* Have a Kubernetes cluster on CAST AI
  * Check [Creating your first cluster](/getting-started/creating-your-first-cluster) if you need guidance.
* `Kubeconfig` downloaded and ready to use for deploying an example application to your cluster.

![](./010_demo_cluster.png)

### 1. Enable relevant policies

In order to get started on using Spot instances autoscaler, you should enable two policies under `Policies` configuration in the UI:

* **Spot/Preemptible instances policy**
  * This policy allows autoscaler to use spot instances
* **Unschedulable pods policy**
  * This policy requests additional workload to be scheduled based on your deployment requires (i.e. run on spot instances)

![](./020_enable_policies.png)

### 2. Example deployment

Save the following _yaml_ file, and name it: `nginx.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        scheduling.cast.ai/spot: "true"
        topology.cast.ai/csp: "aws"
      tolerations:
        - key: scheduling.cast.ai/spot
          operator: Exists
      containers:
        - name: nginx
          image: nginx:1.14.2
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: '2'
            limits:
              cpu: '3'
```

## 2.1. Apply the example deployment

With Kubeconfig set in your current shell session, you can execute the following (or use other means of applying deployment files): 

`kubectl apply -f ngninx.yaml`

![](./030_deployment_in_lens.png)

## 2.2. Wait several minutes

Once the deployment is created, it will take up to several minutes for the autoscaler to pick up the information about your pending deployment, and schedule the relevant workloads in order to satisfy the deployment needs, such as:

* This deployment **tolerates spot instances**
* This deployment **must run only on spot instances**

### 3. Spot Instance added

* You can see your newly added spot instance under the cluster node list.

![](./040_spot_instance_added.png)


### 3.1. AWS instance list

Just to double check, one can go to AWS console, and check that the added node, has `Lifecycle: spot` indicator.

![](./050_aws_node_list.png)
