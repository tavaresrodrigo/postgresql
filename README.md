# PostgreSQL Database on Kubernetes with StatefulSet

## The high level setup 

### [StatefulSet](../manifests/StatefulSet.yaml)

StatefulSet are used to manage deployments providing guarantees about the ordering and uniqueness of the Pods, like a Deployment, a StatefulSet manages Pods that are based on an identical container spec, however it also maintains a sticky identity used to provide persistent identifier for the Pods, StatefulSets ara indicated to Stateful applications like Databases that requires unique network identifiers, persistent storage graceful deployment and scaling and automated rolling updates.
