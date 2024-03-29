---
description: Introduction to CAST AI Cost reporting dashboard
---

# Introduction

The main purpose of the Cost report is to provide information about the cluster compute cost, cost allocation across workloads and namespaces, as well as its fluctuation over different time periods. The report is available as soon as the cluster is connected to CAST AI, and the underlying data is refreshed every 60 seconds.

Cost reporting includes three separate sections:

- Cluster - compute cost report, including normalized compute costs and daily costs.

- Workloads - compute cost broken down by workload, with some additional information like controller type and namespace.

- Namespaces - compute cost broken down by namespace, including normalized CPU cost, on-demand, spot, and fallback CPU cost.

## Concepts

Total cluster compute cost - the total monthly cost of compute resources provisioned on a cluster.

Normalized cost per 1 CPU - the **total cluster compute cost** divided by the **total number of CPUs** provisioned on a cluster. Subtotals of this number will also be calculated for spot, on-demand, and fallback instances.

Workloads - a workload is an application running on Kubernetes.

Namespaces - a namespace provides a mechanism for isolating groups of resources within a single cluster. The names of resources need to be unique within a namespace but not across namespaces. Namespace-based scoping is applicable only for namespaced objects (e.g., Deployments, Services, etc.) and not for cluster-wide objects (e.g., StorageClass, Nodes, PersistentVolumes, etc.).

## Sections

The CAST AI Cost report includes three sections with different levels of granularity - total cluster compute cost report, workload cost report, and namespace cost report. The information below is split by the report.

### Cluster (Total compute cost)

Cluster cost report consists of **compute spend**, **normalized cost per CPU** and **daily compute cost details** views. CAST AI uses public cloud inventory data to calculate cluster compute costs. Custom pricing models are not reflected in our reports at this time.

The report differs depending on the selected date filter, so the information below is split into two sections.

#### **Date filter: This month**

- Current month spend: Sum of all complete days spend + sum of projected
today's spend

- Monthly forecast: Takes into account all complete days and forecasts
spending until the end of the month using 7-day moving average, e.g.,
tomorrow's average spend is the sum of today's spend + the last 6 days divided
by 7. The day after tomorrow is calculated similarly, including
tomorrow's projection.

- Average daily cost: The sum of all complete days' spend divided by the number of
complete days.

- Average cost per CPU:

    - Monthly - A monthly cluster compute cost forecast divided by an average number of provisioned CPUs in the period.
    - Daily - An average daily cluster compute cost divided by an average provisioned CPUs in the period.
    - Hourly - An average hourly cluster compute cost divided by an average provisioned CPUs in the period.

- Projected end of the day spend: Current day's total spend (complete hours) +
average spent per hour multiplied by remaining time. This can also be
broken down by on-demand, fallback, and spot spend.

#### **Date filter: Any past date (day or hour)**

- Compute spend: Actual cluster compute spend in the selected period.

- Avg. monthly cost: Actual cluster compute spend extrapolated into full
monthly spend.

- Avg. daily cost: Total cluster compute cost in the selected period
divided by days in the selected period.

- Avg. cost per CPU: Monthly - An avg. monthly cluster compute cost divided
by an average provisioned CPUs in the period. Daily - An avg. daily cluster
compute cost divided by an average provisioned CPUs in the period. Hourly -
An avg. hourly cluster compute cost divided by an average provisioned CPUs in
the period.

- Total compute spend: Total cluster cost in the selected period broken
down by on-demand, fallback, and spot.

#### Other metrics

Normalized cost per CPU is calculated as follows:

- Hourly: Average hourly CPU cost divided by an average hourly provisioned CPUs.

- Daily: Average hourly CPU cost divided by an average hourly provisioned CPUs and multiplied by 24.

- Monthly: Average hourly CPU cost divided by an average hourly provisioned CPUs and multiplied by 730.

Different cost periods will yield different results, i.e. you can select to view monthly, daily, or hourly CPU cost rate.

Daily compute cost details are calculated similarly (all metrics are calculated per hour):

- Normalized CPU: Total day's CPU cost divided by day's provisioned CPUs.

- On-demand: Total day's On-demand CPU cost divided by day's provisioned On-demand CPUs.

- Spot: Total day's Spot CPU cost divided by day's provisioned Spot CPUs.

- Fallback: Total day's Fallback CPU cost divided by day's provisioned Fallback CPUs.

### Workloads

Workloads report uses the same underlying data as the cluster Cost report. This report allows you to view your cluster costs broken down by workload. Additional information includes controller type, namespace, and information about replicas, CPU requests, and costs. Changing the date filter does not impact logic of how costs are calculated (unlike in the total compute cost report).

- Replica: Average hourly replica count (rounded to integer).

- CPU: Average hourly CPU requests (rounded to 3 decimal numbers).

- $ per CPU: Average hourly cost divided by average hourly CPU requested count.

- Total cost: Sum of all pod costs per workload.

### Namespaces

This report allows you to view your cluster costs broken down by the namespace. Daily compute cost details for all namespaces are calculated similarly (all metrics are calculated per hour):

- Normalized CPU per namespace: Total day's CPU cost divided by day's provisioned CPUs.

- On-demand: Total day's On-demand CPU cost divided by day's provisioned On-demand CPUs.

- Fallback: Total day's Fallback CPU cost divided by day's provisioned Fallback CPUs.

- Spot: Total day's Spot CPU cost divided by day's provisioned Spot CPUs.

- Total cost: Sum of all compute costs associated with the workloads in a namespace.
