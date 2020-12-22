# Spot Instances

In this step-by-step guide we demonstrate how to use Spot Instances with your CAST AI clusters. 

## 1. Pre-requisite: CAST AI cluster

![](./010_demo_cluster.png)

## 2. Enable policies

![](./020_enable_policies.png)

## 3. Deployment

![](./030_deployment_in_lens.png)

## 4. Spot Instance added

![](./040_spot_instance_added.png)


## 4.1. AWS instance list

![](./050_aws_node_list.png)


## Deploying pods on Spot instances

CAST AI Autoscaler, when enabled, supports adding Spot Nodes. In order to signal that a pod can run on spot instance, you should add a toleration to your pod:

```yaml
...
tolerations:
  - key: scheduling.cast.ai/spot
    operator: Exists
...
```

### Modes

#### Toleration-only

If pod is marked only with Toleration, Kubernetes scheduler could place such pod(s) on regular nodes as well. Example:

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

#### Toleration + Spot NodeSelector

In order to make sure that a pod is scheduled to spot instances only, you should add node selector:

```yaml
nodeSelector:
  scheduling.cast.ai/spot: "true"
```

Full example:

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
