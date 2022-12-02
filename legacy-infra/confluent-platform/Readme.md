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

## Install Connect
ensure all secrets are present as env vars (in this case as they come form terraform output)
* _TF_VAR_confluent_cloud_api_key_
* _TF_VAR_confluent_cloud_api_secret_
* _TF_VAR_confluent_schema_registry_api_key_
* _TF_VAR_confluent_schema_registry_api_secret_
```shell
sed -e "s|@@TF_VAR_confluent_cloud_api_key@@|${TF_VAR_confluent_cloud_api_key}|g" \
-e "s|@@TF_VAR_confluent_cloud_api_secret@@|${TF_VAR_confluent_cloud_api_secret}|g" \
-e "s|@@TF_VAR_confluent_schema_registry_api_key@@|${TF_VAR_confluent_schema_registry_api_key}|g" \
-e "s|@@TF_VAR_confluent_schema_registry_api_secret@@|${TF_VAR_confluent_schema_registry_api_secret}|g" \
values.yaml | helm install connect -f - cp-helm-charts/charts/cp-kafka-connect
```