# Overview

Monitor your Kubernetes cluster security and hygiene using CAST AI Security Report’s features.

## Features

### Best Practices Checks

CAST AI Security Report’s Best Practices checks assess customer clusters against good security and DevOps practices based on CIS Kubernetes Benchmark, NSA, OWASP, and PCI recommendations for Kubernetes. We introduced a transparent issues scoring and prioritization system for these checks, so customers could easily prioritize the problems and spend their effort where needed.

### Image scanning

Be informed about vulnerabilities detected in operating system packages and libraries when running images in Kubernetes clusters monitored by the CAST AI. CAST AI assesses your private image for known vulnerabilities once CAST AI detects it in the cluster. Vulnerability information comes from various vulnerability databases and security advisories. Runtime vulnerability scan detects vulnerabilities that have bypassed the security scan in the deployment environment.

## How it works

CAST AI Security Report leverages cluster state data collected by the [CAST AI Kubernetes Agent](https://docs.cast.ai/product-overview/hosted-components/#phase-1-component-cast-ai-kubernetes-agent), so all you need is to connect your [Azure AKS](https://docs.cast.ai/getting-started/aks/aks/#connect-cluster), [AWS EKS](https://docs.cast.ai/getting-started/eks/eks/#connect-cluster), [kOps](https://docs.cast.ai/getting-started/kops/kops/#kops) or [GCP GKE](https://docs.cast.ai/getting-started/gke/gke/#connect-cluster) cluster to the CAST AI cloud platform. Then CAST AI cloud platform analyses cluster state data and provide you with security insights via the [CAST AI Console](https://docs.cast.ai/product-overview/console/security-insights/).
