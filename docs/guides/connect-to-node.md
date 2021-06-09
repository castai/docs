---
description: This guide show you how to connect to your cluster node via Kubernetes or native ssh. Take a look and explore CAST AI.
---

# Connect to node

This guide describes how to connect to your cluster node via Kubernetes or native ssh.

## Connect via node-shell Kubernetes plugin

With node-shell Kubernetes plugin you can connect into your node via Kubernetes API Server as a proxy.

### Install node-shell

using [krew](https://krew.sigs.k8s.io/):

```bash
kubectl krew index add kvaps <a href="https://github.com/kvaps/krew-index">https://github.com/kvaps/krew-index</a>
kubectl krew install kvaps/node-shell
```

or using curl:

```bash
curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
chmod +x ./kubectl-node_shell
sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
```

### Example node-shell usages

```bash
# Get standard bash shell
kubectl node-shell <node>

# Execute custom command
kubectl node-shell <node> -- echo 123

# Use stdin
cat /etc/passwd | kubectl node-shell <node> -- sh -c 'cat > /tmp/passwd'

# Run oneliner script
kubectl node-shell <node> -- sh -c 'cat /tmp/passwd; rm -f /tmp/passwd'
```

*You need to be able to start privileged containers for that.*

## Connect via Lens UI

[Lens](https://github.com/lensapp/lens) is a great Kubernetes UI tool which has builtin functionality to connect into cluster node.

## Connect via native ssh

With native SSH you can connect directly into your node without Kubernetes API.

### Install CAST CLI

Install official [CAST CLI](https://github.com/castai/cli)

### Example CAST CLI usage

```
cast -c=cluster-name node ssh my-node-name
```

**When to use native ssh with CAST CLI?**

* Your Kubernetes cluster is not working properly (Kubernetes API Server is not accessible etc.)
* You need native SSH performance, eg: packet tracing with tcpdump etc. Kubernetes node-shell plugin
spin ups a new pod with root access and proxies to Kubernetes API Server which is slower that direct SSH connection.
