# Confluent Platform
Instructions to install and configure Confluent Platform in the kubernetes cluster.

see https://www.confluent.io/blog/how-to-connect-ksql-to-confluent-cloud-using-kubernetes-with-helm/
see https://github.com/confluentinc/cp-helm-charts

## Install Confluent Operator
```shell
 helm repo add confluentinc https://packages.confluent.io/helm
 helm repo update
 helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
```

## Create secrets from env variables
ensure all secrets are present as env vars (in this case as they come form terraform output)
* _TF_VAR_confluent_cloud_api_key_
* _TF_VAR_confluent_cloud_api_secret_
* _TF_VAR_confluent_schema_registry_api_key_
* _TF_VAR_confluent_schema_registry_api_secret_

and run this script:
```shell
./create-secrets.sh
```

## Install Connect
```shell
git clone https://github.com/confluentinc/cp-helm-charts.git
#helm install cp-helm-charts
#helm install connect --set kafka.bootstrapServers="SASL_SSL://pkc-n6183.us-central1.gcp.confluent.cloud:9092",cp-schema-registry.url="https://pkc-n6183.us-central1.gcp.confluent.cloud:443" cp-helm-charts/charts/cp-kafka-connect
helm install connect -f values.yaml cp-helm-charts/charts/cp-kafka-connect
```