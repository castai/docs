## Overview

This is a quick overview of the dashboard and it's features.

- ### /dashboard

In the dashboard window you will see all active and deleted clusters.

1. Create a new cluster. If you can see only an option to create a cluster, please refer to [Getting started] to unlock other features.
2. Download KubeConfig of a cluster, pause or delete it.
3. You can open any specific cluster to manage its policies, add or remove nodes or check logs (check -> /clusters). Copy cluster ID for API management.

[screenshot]

- ### /clusters

When you open any cluster from the /dashboard menu you will arrive to /clusters management.

Here you will see more information about the selected cluster and will get access to the cluster management menu.

1. Quickly navigate through active clusters.
2. Information and log of the selected cluster.
3. Management menu.

[screenshot]

  - #### /nodes
  
  View information about the selected cluster nodes and manage them here.
  
  1. Add a new node.
     - If your cluster runs on multiple clouds you will be able to specify a cloud provider for the node(s).
     - Specify a CAST shape for the node(s) - a virtual specification of a Virtual Machine computing unit.
     - Add multiple nodes at once (1-20).
     
  2. View information about nodes, copy node ID for API management and delete nodes.
  
  [screenshot]
  
  - #### /audit
  
  Audit log of cluster management on a high level.
  
  1. Select a date range for the log.
  2. View operations made and who initiated them.
  
  [screenshot]
  
  - #### /policies
  
  Manage policies for the selected cluster. Policies will help you optimize and reduce cost of your cloud bill and will automate the process of scaling up and down for you.
  
 [screenshot]
  
  - #### Kubernetes UI
  
  View more detailed information about the selected cluster in the Kubernetes UI.
  
  - #### Kibana logs
  
  
  
  - #### Grafana logs
  
  
  
  
  
