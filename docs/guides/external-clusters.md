---
description: Learn more about the CAST AI agent, connection of external clusters to CAST and get help if you need to do some troubleshooting.
---

# External cluster troubleshooting

This guide is intended for users who are experiencing issues while connecting their EKS, GCP or AKS clusters to CAST AI. Once cluster is connected you can check the `Status` field in the **Clusters overview** screen to understand if cluster is operating as expected.

![](external-clusters/cluster-dashboard.png)

Further sections will cover most common issues and how to resolve them.

## Your cluster does not appear in the Connect Cluster screen

If a cluster is not appearing in the Connect your cluster screen after you've run the connection script, perform following steps.

1. Check the Pod logs:

    ```sh
    kubectl logs -n castai-agent -l app.kubernetes.io/name=castai-agent
    ```

2. You might get output similar to this:

    ```text
    time="2021-05-06T14:24:03Z" level=info msg="starting the agent"
    time="2021-05-06T14:24:03Z" level=info msg="using cluster provider discovery"
    time="2021-05-06T14:24:03Z" level=fatal msg="agent failed: registering cluster: getting cluster name: describing instance_id=i-026b5fadab5b69d67: UnauthorizedOperation: You are not authorized to perform this operation.\n\tstatus code: 403, request id: 2165c357-b4a6-4f30-9266-a51f4aaa7ce7"
    ```

This particular example indicates that we failed to collect the relevant data required to identify your cluster on our system.

To solve this issue:

1. Create a deployment file such as this:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: castai-agent
      namespace: castai-agent
      labels:
        "app.kubernetes.io/name": castai-agent
    spec:
      replicas: 1
      selector:
        matchLabels:
          "app.kubernetes.io/name": castai-agent
      template:
        metadata:
          labels:
            "app.kubernetes.io/name": castai-agent
        spec:
          serviceAccountName: castai-agent
          containers:
            - name: autoscaler
              image: k8s.gcr.io/cpvpa-amd64:v0.8.3
              command:
                - /cpvpa
                - --target=deployment/castai-agent
                - --namespace=castai-agent
                - --poll-period-seconds=300
                - --config-file=/etc/config/castai-agent-autoscaler
              volumeMounts:
                - mountPath: /etc/config
                  name: castai-agent-autoscaler
            - name: agent
              image: "castai/agent:v0.19.2"
              env:
                - name: API_URL
                  value: api.cast.ai
                - name: PROVIDER
                  value: "eks"
              envFrom:
                - secretRef:
                    name: castai-agent
              resources:
                requests:
                  cpu: 100m
                limits:
                  cpu: 1000m
          volumes:
            - name: castai-agent-autoscaler
              configMap:
                name: castai-agent-autoscaler
    ```

2. Add the values for the missing parts next to the `#FILL THIS` comment.

3. Apply the deployment file using `kubectl apply -f deployment.yaml`.

## Refused connection to controlplane

When enabling cluster optimization for the first time user runs the pre-generated script to grant required permissions to CAST as shown below.

![](external-clusters/enable-optimization.png)

Error message **No access to Kubernetes API server, please check your firewall settings** indicates that firewall prevents communication between control plane and CAST AI.

To solve this issue permit access to CAST AI IP `35.221.40.21` then enable optimization again.

## Disconnected or Not responding cluster

If cluster has a `Not responding` status - most likely CAST AI agent deployment is missing, press **Reconnect** and follow the instructions provided.

![](external-clusters/reconnect-cluster.png)

`Not responding` state is temporary and if not fixed cluster will go in to `Disconnected` state. Disconnected cluster can be reconnected or deleted from console as show.

![](external-clusters/disconnected-cluster.png)

Delete action only removes cluster from CAST AI console leaving it running in CSP.

## Out-dated CAST AI agent version

To check which agent version is running on your cluster run the following command:

  ```sh
  kubectl describe pod castai-agent -n castai-agent | grep castai/agent:v
  ```

You can cross-check our [Github repository](https://github.com/castai/k8s-agent) for a number of the latest version available.

In order to upgrade CAST AI agent version please perform following steps:

1. Go to [Connect cluster](https://console.cast.ai/external-clusters/new)
2. Select correct cloud service provider
3. Run the provided script

Latest version of CAST AI agent is now deployed in your cluster.

## Deleted agent

In case CAST AI agent deployment got deleted from the cluster, you can re-install the agent by re-running the script from [**Connect cluster**](https://console.cast.ai/external-clusters/new) screen. Please ensure you have chosen the correct cloud service provider.

!!! tip
      If you are still encountering any issues, ping us with logs output at:
      <https://castai-community.slack.com/>
