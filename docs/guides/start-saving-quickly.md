# Start saving on your external cluster [EKS] immediately

If you liked the numbers you saw in Savings Estimator after connecting your existing EKS cluster to CAST.AI and don't
want to wait until saving reach you in a slow, on-going process without risks. You could hasten these saving by helping
yourself.

## Register your external cluster

You need to register, which means create IAM user for CAST.AI to optimize your external cluster

## Enable Policies

1. **Enabled Node deletion** policy, this policy will remove Nodes without PODs (ignores daemonSets)

2. **Enable Unscheduled Pod** policy, it will make sure, you always have capacity in the cluster to run PODs. Unscheduled
Pod policy will provision new node, which takes 2-3 minutes.

3. **Adjust headroom %** for migration purposes, Each node adds overhead through daemonSets and means more PODs won't find their destination on 
the same node (added latency), so ideally one should have as big nodes as possible, but 5-6 nodes at the minimum (for 
below 200 CPUs cluster) for good SLA and adequate capacity distribution for lifecycle process (upgrades, patching). Take
number from Available Savings - total amount of nodes you should have in Optimized state.
![](start-saving-quickly/amount_of_nodes.png)
```
headroom percentage = 100 / Amount_of_Nodes_in_suggest_optimased_state
```
In Policies tab it should look like 
![](start-saving-quickly/policies.png)

# "Slow and safe" or "maximize savings now"

Evictor is our recommended way, it will constantly look for inefficiencies, but to reduce costs in a safe manner takes
time. If you want to maximize your savings as quick as possible and you have a maintenance window you can do it.

## Install Evictor (continues improvements)

Evictor will compact your PODs in to fewer nodes, creating empty nodes which will be removed by Node deletion policy:
```
helm repo add castai https://castai.github.io/official-addons
helm -n kube-system upgrade -i evictor castai/evictor --set dryRun=false
```
This process will take some time, also evictor will not cause downtime so single replica deployments / statefulSets, PODs
without ReplicaSet would mean those nodes can't be removed in a graceful manner.

## Stir the pod with manual migration

You will have to get rid of your existing Nodes, and let CAST.AI create Optimized state right away. It might cause some
downtime depending on your workloads configuration

Pick say 50% of your nodes in one availability zone (AZ), or 20% of nodes if your external cluster is in single AZ.
```
kubectl get nodes -Lfailure-domain.beta.kubernetes.io/zone --selector=eks.amazonaws.com/nodegroup-image
```
Percentage is arbitrary, depends on your risk appetite and how much you want to spend time on this. Taint (cordon) 
selected nodes, so no new PODs will be place on these nodes. I like Lens k8s ide, but you can use kubectl as 
well: 
```
kubectl cordon nodeName1
kubectl cordon nodeName2
```
and now drain these nodes:
```
kubectl drain nodeName1 --ignore-daemonsets --delete-local-data
kubectl drain nodeName2 --ignore-daemonsets --delete-local-data
```
Some nodes will not drain, because Disruption Budget violation (downtime), these cases should be fixed as will 
cause pain in the future, or at least noted to address when convenient. If you want to progress anyway and accept
downtime, cancel drain command and retry drain with additional --force flag.

You should see that drained nodes disappear (empty Node deletion policy) and in few moments new nodes in same 
availability zone appear (unscheduled POD policy with Headroom).
Check remaining nodes, you will see that list is shorter, because below command select only nodes in AWS autoscaling
group (ASG), new nodes do not use ASG.
```
kubectl get nodes -Lfailure-domain.beta.kubernetes.io/zone --selector=eks.amazonaws.com/nodegroup-image
```
Select next batch -> cordon -> drain -> write down problematic PODs which do not migrate easily -> rince and repeat until
list is empty.

## Utilize Spot

In Available saving window there are list of Deployments which could be using Spot instances. I have recommendation 
service running with 10 replicas.
![](start-saving-quickly/spot_deployments.png)
I could separate this workload to two deployments:
1. reduce current replica count to bare minimum (in my case 2 replicas),
2. create copy of deployment with "_spot" appending name, add toleration and set to 8 replicas, or beter configure to
use KEDA see [HPA documentation](../guides/hpa.md)
```yaml
...
tolerations:
  - key: scheduling.cast.ai/spot
    operator: Exists
...
```

## You're all done

* Share available savings window screenshot with your CFO/manager - there is nothing left to save.

* Reduce Headroom policy to smaller number, which would fit your smoother organical growth better

* Install evictor, if you haven't done that above
