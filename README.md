
<!modificacao teste>
# PostgreSQL Database on Kubernetes with StatefulSet

StatefulSets are indicated to Stateful applications like Databases that requires unique network identifiers, persistent storage graceful deployment and scaling and automated rolling updates.

## The high level setup 

In order to reproduce on a smaller scale a scenario where backups and restores for PostgreSQL are implemented with pgBackRest to support 10000 distinct database deployments, and all databases run in a single Kubernetes cluster with high availability in mind. I have created a EKS Kubernetes Cluster v 1.17 on AWS with two nodes in different AZ each and EBS Persistent Volumes using the default gp2 Storage Class.

### [StatefulSet](../master/manifests/StatefulSet.yaml)

StatefulSet are used to manage deployments providing guarantees about the ordering and uniqueness of the Pods, like a Deployment, a StatefulSet manages Pods that are based on an identical container spec, however it also maintains a sticky identity used to provide persistent identifier for the Pods.

### [PersistentVolumeClaim](../master/manifests/PersistentVolumeClaim.yaml)

Persistent Volume Claims are objects that connect to back-end storage volumes through a series of abstractions. They request the storage resources that your deployment needs.

The PersistentVolumeClaim implements an EBS PersistentVolume in AWS using the default gp2 Storage Class. Kubernetes persistent volumes are user-provisioned storage volumes assigned to a Kubernetes cluster, since the Persistent volumes’ life-cycle is independent from any pod using it, they retain data regardless of the unpredictable life process of Kubernetes pods. PersistentVolumes are perfect for Stateful workloads like Databases.

### [Secret](../master/manifests/Secret.yaml)

Kubernetes Secrets allow us store sensitive information, such as the Postgres database name, user and password. Storing confidential information in the Secret is safer and more flexible than putting it in a ConfigMap or even hardcoding somewhere else. 

### [Service](../master/manifests/Service.yaml)

A Headless Service was created to expose the Postgres statefull Pods into the scope of the VPC cluster only. Exposing the data tier service with a cluster-internal endpoint is considered a best practice in compliance with the AWS Well-Architected Framework which consists in the 5 pillars: operational excellence, security, reliability, performance efficiency, and cost optimization.

### [Namespace](../master/manifests/Namespace.yaml)

Implementing the postgresql namespace, we allow the administrator to divide cluster resources, apply network policies, implement quotas, and implement fine adjustments on the resources and objects into the namespace.

## Common issues during the backup and restore 

On Monday August 10, 2020 there were [3 closed issues]( https://github.com/pgbackrest/pgbackrest/issues?q=is%3Aissue+Kubernetes+is%3Aclosed+) on the pgbackrest project page related to Kubernetes, [105 closed issues](https://github.com/kubernetes/kubernetes/issues?q=is%3Aissue+Postgres+is%3Aclosed) and [17 open issues](https://github.com/kubernetes/kubernetes/issues?q=is%3Aissue+Postgres+is%3Aopen) related to Postgres on the Kubernetes project page, there are multiple root causes that are related to a number of factors as we can see below:

* DNS resolution.
* Problems to configure Secrets and ConfigMaps.
* Autoscaling.
* Performance issues during the backup and restore operations.
* Timeout issues.

## How to mitigate and prevent these issues ? 

Most of the DNS resolution issues are related to CoreDNS not having the enough capacity to process the DNS queries into the cluster, by enabling the [CoreDNS Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/administer-cluster/dns-horizontal-autoscaling/) we allow the cluster to adjust the required capacity in order to process the cluster DNS queries according to the demand. 

[Readiness and Liveness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) are useful to mitigate timeout issues when the services forward requests to Pods that are not ready yet or Pods that eventually transition to broken state.

By configuring [resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) we allow the scheduler to decide which node to place the Pod based on the capacity available. Limits allows kubelet to enforces the values we set so that the running container is not allowed to use more of that resource than the limit you set, avoiding the instances to be overwhelmed running out of resources.

With the [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) the cluster will automatically scale the pods in a deployment, statefulset or replicaset based on a HorizontalPodAutoscaler definition adjusting to ensure the application will meet the performance criteria.

The [Cluster Autoscaler (CA)](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) a component that automatically adjusts the size of the Cluster watching for Pods on the Pending state to be schedule due to the lack of resources, this event will trigger the increase of the capacity by adding new nodes.

## Architecture

Since the Kubernetes cluster is running on top of AWS Infrastructure with AWS EKS, a good approach to design the application architecture is to use the AWS [Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/?wa-lens-whitepapers.sort-by=item.additionalFields.sortDate&wa-lens-whitepapers.sort-order=desc), which describes the key concepts, design principles, and architectural best practices for designing and running workloads in the cloud.

To support 10000 distinct database Pods simultaneously, the m5d.16xlarge instances can be a good option, with a limit of 737 ips per instance 14 instances spread across different AZs would be enough to afford the workload from the network perspective, in addition this is one of the instances types recommended by AWS as a good choice for many database workloads. A well designed and architected application must consider a series of functional requirements as SLA, Recoverability, Security, Capacity, Availability, Scalability and Maintainability.

## Tooling 

The native functionality provided by the container engine or runtime is usually not enough for a complete logging solution, logs should have a separate storage and lifecycle independent of nodes, pods, or containers (cluster-level-logging). Cluster-level logging requires a separate backend to store, analyze, and query logs,. since Kubernetes provides no native storage solution for that, a good approach is to adopt a set of third-party tools.

Fluent Bit, Elasticsearch and Kibana are also known as “EFK stack”. Fluent Bit will forward logs from the individual instances in the cluster to a centralized logging backend where they are combined for higher-level reporting using ElasticSearch and Kibana.

* Prometheus
* Helm-3
* Grafana
* Fluent Bit
* Kibana
* metris-server

## Monitoring

Prometheus is a time-series based, open source systems monitoring tool which joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes. Prometheus collects metrics via a pull model over HTTP automatically discovering targets using Kubernetes API. There is a [Prometheus exporter](https://github.com/wrouesnel/postgres_exporter) for PostgreSQL server metrics.

## On-call challenges 

One of the main challenges a pearson on call can face is in order to identify and prioritize the pages/tickets/events/incidents. Engineers on call must have a clear guideline and be aware of the expected actions regarding each severity case, based on the SLA the engineer will be able to determine which incident deserve more attention in case there are multiple events simultaneously. 

In order to diagnose, mitigate, fix, or escalate production incidents the best approach is to automate operational tasks as much as possible. Manual interventions in production must of the time will represent more chances to create a negative impact to the operation.

The on-call can be tricky when engineer gets paged about a hundred times during the shift, there must be a reasonable target of incidents per on-call shift in order to ensure adequate time for follow-up.

Handover incidents at the end of the shift is important to allow the next SREs on the shift to keep the same quality and the same attention required by the event. At the start of each shift, the on-call engineer must read the handoff from the previous shift. 

Maintaining Playbooks and the knowledge base can be tough, details in playbooks go out of date at the same rate as production environment, products and technologies evolute. Writing playbooks and keeping them update must be a share responsibility among all the SREs on call, it must be part of the principal activities on a daily basis. 

SREs on call must be able to engage SMEs, or must tenured engineers if they need help, sometimes troubleshooting new issues that are not catalogued must required the engagement of different areas, engineers on call must know how to use the communication channels in order to be in contact with the right team when required.

