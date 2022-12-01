# Client hosted infrastructure 
Instructions to provision the legacy client existing infra plus the changes that are needed to publish its data into Confluent.

_Please note that these steps must be executed in order_

Existing infrastructure:
* see [Kubernetes cluster](kubernetes-cluster/Readme.md) to provision the kubernetes cluster on which the applications will be deployed.
* see [Postgres](./postgres/Readme.md) to provision the legacy database in the cluster.

Platform setup:
* see [Confluent Platform](./confluent-platform/Readme.md) to provision Confluent Platform in the cluster.