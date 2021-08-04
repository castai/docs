---
description: Tuning node kernel parameters
---

# Tuning node kernel parameters

Kubernetes [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) schedules pod on in each, and we can use it to configure linux kernel parameters.

Using the example below you could configure linux kernel using sysctl depending on your requirements.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-kernel-tuning
spec:
  selector:
    matchLabels:
      app: node-kernel-tuning
  template:
    metadata:
      labels:
        app: node-kernel-tuning
    spec:
      hostNetwork: yes
      initContainers:
        - name: init
          image: alpine:3.14
          command:
            - /bin/sh
            - -xc
            - |
              sysctl net.ipv4.tcp_keepalive_time=7200
              sysctl fs.inotify.max_user_watches=524288
          securityContext:
            privileged: true
      containers:
        - name: sleep
          image: alpine:3.14
          command:
            - /bin/sh
            - -c
            - |
              while true; do sleep 60s; done
          resources:
            requests:
              cpu: 10m
              memory: 10Mi
            limits:
              cpu: 10m
              memory: 10Mi
```

!!! Note ""
Using DaemonSet is not ideal as it still requires keep dummy pod running on each node. There is an open [issue](https://github.com/kubernetes/kubernetes/issues/64623) to support running one time job on each node.
