# PostgreSQL Database on Kubernetes with StatefulSet

StatefulSets are indicated to Stateful applications like Databases that requires unique network identifiers, persistent storage graceful deployment and scaling and automated rolling updates.

## The high level setup 

In order to reproduce on a smaller scale a scenario where backups and restores for PostgreSQL are implemented with pgBackRest to support 10000 distinct database deployments, and all databases run in a single Kubernetes cluster with high availability in mind. I have created a EKS Kubernetes Cluster v 1.17 on AWS with two nodes in different AZ each and Persistent Volumes with GP2.

### [StatefulSet](../postgresql/manifests/master/StatefulSet.yaml)

StatefulSet are used to manage deployments providing guarantees about the ordering and uniqueness of the Pods, like a Deployment, a StatefulSet manages Pods that are based on an identical container spec, however it also maintains a sticky identity used to provide persistent identifier for the Pods.

### [PersistentVolumeClaim](../postgresql/manifests/master/PersistentVolumeClaim.yaml)

### [Secret](../postgresql/manifests/master/Secret.yaml)

### [Service](../postgresql/manifests/master/Service.yaml)

### [Namespace](../postgresql/manifests/master/Namespace.yaml)


