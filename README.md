# PostgreSQL Database on Kubernetes with StatefulSet

StatefulSets are indicated to Stateful applications like Databases that requires unique network identifiers, persistent storage graceful deployment and scaling and automated rolling updates.

## The high level setup 

In order to reproduce on a smaller scale a scenario where backups and restores for PostgreSQL are implemented with pgBackRest to support 10000 distinct database deployments, and all databases run in a single Kubernetes cluster with high availability in mind. I have created a EKS Kubernetes Cluster v 1.17 on AWS with two nodes in different AZ each and EBS Persistent Volumes using the default gp2 Storage Class.

### [StatefulSet](../blob/master/manifests/StatefulSet.yaml)

StatefulSet are used to manage deployments providing guarantees about the ordering and uniqueness of the Pods, like a Deployment, a StatefulSet manages Pods that are based on an identical container spec, however it also maintains a sticky identity used to provide persistent identifier for the Pods.

### [PersistentVolumeClaim](../blob/master/manifests/PersistentVolumeClaim.yaml)

Persistent Volume Claims are objects that connect to back-end storage volumes through a series of abstractions. They request the storage resources that your deployment needs.

The PersistentVolumeClaim implements an EBS PersistentVolume in AWS using the default gp2 Storage Class. Kubernetes persistent volumes are user-provisioned storage volumes assigned to a Kubernetes cluster, since the Persistent volumes’ life-cycle is independent from any pod using it, they retain data regardless of the unpredictable life process of Kubernetes pods. PersistentVolumes are perfect for Stateful workloads like Databases.

### [Secret](../blob/master/manifests/Secret.yaml)

Kubernetes Secrets allow us store sensitive information, such as the Postgres database name, user and password. Storing confidential information in the Secret is safer and more flexible than putting it in a ConfigMap or even hardcoding somewhere else. 

### [Service](../blob/master/manifests/Service.yaml)

A service type ClusterIP was created to expose the Postgres service into the scope of the VPC cluster only. Exposing the data tier service with a cluster-internal IP is considered a best practice in compliance with the AWS Well-Architected Framework which consists in the 5 pillars: operational excellence, security, reliability, performance efficiency, and cost optimization.

### [Namespace](../blob/master/manifests/Namespace.yaml)

Implementing the postgresql namespace, we allow the administrator to divide cluster resources, apply network policies, implement quotas, and implement fine adjustments on the resources and objects into the namespace.


## Common issues during the backup and restore 

On Monday August 10, 2020 there were [3 closed issues]( https://github.com/pgbackrest/pgbackrest/issues?q=is%3Aissue+Kubernetes+is%3Aclosed+) on the pgbackrest project page related to Kubernetes, [105 closed issues(https://github.com/kubernetes/kubernetes/issues?q=is%3Aissue+Postgres+is%3Aclosed)] and [17 open issues] related to Postgres on the Kubernetes project page, there are multiple root causes that are related to a number of factors as we can see below:

* Issues related to Persistent Volumes
* Cannot pull container image.
* DNS resolution
* Problems to configure Secrets and ConfigMaps
* Autoscaling 
* Performance issues during the backup and restore operations
* Timeout issues

## How to mitigate and prevent these issues ? 

Readiness and Liveness probes, init containers, HPA, CA, 

## Architecture


## Tooling 


## Monitoring


## On-call challenges 



