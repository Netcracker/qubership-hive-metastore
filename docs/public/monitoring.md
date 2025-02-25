This chapter describes the Qubership Hive-Metastore monitoring. Qubership Hive-Metastore monitoring requires Qubership Monitoring installed in the cluster. However, you can try to make it work using [Grafana Operator](https://github.com/grafana/grafana-operator) and [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator).

The following sections are covered in this chapter:

* [Grafana Dashboard](#grafana-dashboard)  
* [Prometheus Rules](#prometheus-rules)

# Grafana Dashboard

This section describes the Qubership Hive-Metastore monitoring dashboard.

![Dashboard Variables](/docs/internal/images/hive_metastore_dashboard_variables.png)

To access the dashboard, navigate to the Grafana server and log in using the provided credentials. Select the Hive-Metastore dashboard and select the `namespace`. Select the operator's `pod` and select the time range.

## Metrics

The Metrix covers the following:

* [Hive-Metastore Overview](#hive-metastore-overview)
* [CPU Usage](#cpu-usage) 
* [Memory Usage](#memory-usage)
* [JVM](#jvm)
* [Disk Space Usage](#disk-space-usage)
* [Network](#network)
* [Data](#data)

### Hive-Metastore Overview

This section describes the Qubership Hive-Metastore overall state.

![Hive-Metastore Overview](/docs/internal/images/hive_metastore_overview.png)

#### Hive-Metastore Status

This section displays the Qubership Hive-Metastore health status.  
In case of several replicas, the status is "UP" if one of the pods is in the "Running" phase.  
This approach is based on the fact that only one of the replicas is always active.

#### Active Replicas Count

This displays the number of Qubership Hive-Metastore running pods.  
Only one pod, which is the leader, is active.

#### Pods Count

This displays the number of pods in the namespace.

#### Pod Status

This displays the status of the pod.

The possible values are:

* Failed
* Pending
* Running
* Succeeded
* Unknown

### CPU Usage

This displays the CPU consumption in Qubership Hive-Metastore pods based on the metrics collected from the docker.

![CPU](/docs/internal/images/hive_metastore_cpu.png)

### Memory Usage

This displays the memory consumption in Qubership Hive-Metastore pods based on the metrics collected from the docker.

![alt text](/docs/internal/images/hive_metastore_memory.png "Memory")

### JVM

This section describes the Qubership Hive-Metastore JVM state.

![Hive-Metastore JVM](/docs/internal/images/hive_metastore_JVM.png)

#### JVM Heap Usage

This section displays the JVM heap usage by Qubership Hive-Metastore.

#### Threads

This section displays the threads rate per second by Qubership Hive-Metastore.

#### GC Time

This section displays the garbage collection time rate per second by Qubership Hive-Metastore.

### Disk Space Usage

This section displays the disk usage for Qubership Hive-Metastore pods.

![Disk](/docs/internal/images/hive_metastore_space.png)

### Network

This section displays the network information.

![Network](/docs/internal/images/hive-metastore_network.png)

### Open Connection

This section displays open connections to Qubership Hive-Metastore.

#### Receive/Transmit Bandwidth

This section displays the network traffic in bytes per second for the pod.

#### Rate of Received/Transmitted Packets

This section displays the network packets for the pod.

#### Rate of Received/Transmitted Packets Dropped

This section displays the dropped packets for the pod.

### Data

This section describes the Qubership Hive-Metastore data state.

![Hive-Metastore data](/docs/internal/images/hive_metastore_data.png)

#### DB

This displays the count DB (databases) of the Qubership Hive-Metastore. 
Count DB - The total number of databases created.
Delete DB - The number of deleted databases over a period of time. 

# Prometheus Rules

This section describes the Prometheus rules configured for the Qubership Hive-Metastore.

## Alerts

The following alerts are configured for the Qubership Hive-Metastore.

### Hive-Metastore CPU Usage

When some of Qubership Hive-Metastore pods' CPU load is higher than `prometheusRules.alert.cpuThreshold`, Prometheus fires an alert.    
The threshold is the percentage of the CPU limit specified for the pod.

### Hive-Metastore Memory Usage

When some of Qubership Hive-Metastore pods' memory usage is higher than `prometheusRules.alert.memoryThreshold`, Prometheus fires an alert.    
The threshold is the percentage of the memory limit specified for the pod.

### Hive-Metastore is Degraded

If some of the Qubership Hive-Metastore pods go down, Prometheus fires an alert.

### Hive-Metastore is Down

If none of the Qubership Hive-Metastore pods are in the 'Running' phase, Prometheus fires an alert notifying that the operator is down.
