# Cluster lifecycle

## 1. Provisioning

You initiate the creation of the cluster - see [create cluster](../getting-started/create-cluster.md).

### 2. Reconciliation & healing

A cluster enters a reconciliation loop. The platform periodically re-checks that actual infrastructure on your cloud reflects the specified configuration, and performs upgrades & patching. Reconciliation performs checks such as:

- [x] Cluster network configuration is up to date;
- [x] Are any nodes missing, e.g. accidentally deleted;
- [x] Are there any unused resources to clean up;

### 3. Resizing

CAST AI clusters do not use a "node pool" concept. Instead, you can:

- Manually add or remove nodes with the specified configuration.
- Enable autoscaling policies - it scales up and down per-node level.

### 4. Cleanup

When you delete a cluster platform will collapse cloud resources in the quickest way. Nodes will not be drained before deleting them.

The platform is designed to minimize unintended removals. If you have any extra virtual machines that do not contain CAST AI cluster UUID - the delete operation will fail.
