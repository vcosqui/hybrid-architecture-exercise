# Confluent Platform
Instructions to install and configure Confluent Platform in the kubernetes cluster.

see https://www.confluent.io/blog/how-to-connect-ksql-to-confluent-cloud-using-kubernetes-with-helm/

## Install Confluent Operator
```shell
 helm repo add confluentinc https://packages.confluent.io/helm
 helm repo update
 helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
```

## Install Connect
```shell
git clone https://github.com/confluentinc/cp-helm-charts.git
#helm install cp-helm-charts
#helm install connect --set kafka.bootstrapServers="SASL_SSL://pkc-n6183.us-central1.gcp.confluent.cloud:9092",cp-schema-registry.url="https://pkc-n6183.us-central1.gcp.confluent.cloud:443" cp-helm-charts/charts/cp-kafka-connect
helm install connect -f values.yaml cp-helm-charts/charts/cp-kafka-connect
```