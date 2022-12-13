# Confluent Platform
Instructions to install and configure Confluent Platform in the kubernetes cluster.

see https://docs.confluent.io/operator/current/co-configure-connect.html#download-connector-plugins-from-a-custom-url
see https://github.com/confluentinc/confluent-kubernetes-examples/tree/master/hybrid/ccloud-JDBC-mysql

## Install Confluent Operator
```shell
helm repo add confluentinc https://packages.confluent.io/helm
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
kubectl get pods
```

## Create Kubernetes Secrets for Confluent Cloud API Key and Confluent Cloud Schema Registry API Key
ensure all secrets are present as env vars (in this case as they come form terraform output)
* _TF_VAR_confluent_cloud_api_key_
* _TF_VAR_confluent_cloud_api_secret_
* _TF_VAR_confluent_schema_registry_api_key_
* _TF_VAR_confluent_schema_registry_api_secret_
```shell
./create-credentials.sh
```

## Deploy self-managed Kafka Connect connecting to Confluent Cloud
```shell
kubectl apply -f ./kafka-connect.yaml
```






# JDBC connector

see: https://turkogluc.com/kafka-connect-jdbc-source-connector/

## Install JDBC Connector plugin
Run the following command to install the JDBC plugin in the only connect pod
```shell
./create-credentials.sh
```


curl -X POST -H "Content-Type: application/json"  --data '{ "name": "jdbc-grocery-shop", "config": { "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
"connection.url": "jdbc:postgres:5432/merchant?schema=merchant&user=merchant&password=m3rch4nt", "schema.pattern": "merchant", "catalog.pattern": "merchant", "table.whitelist": "sellers,customers,products,orders", "tables": "sellers,customers,products,orders", "mode": "timestamp", "timestamp.column.name":"updated_at", "topic.prefix": "postgres.grocery_shop.", "transforms": "ValueToKey,extractField", "transforms.ValueToKey.type": "org.apache.kafka.connect.transforms.ValueToKey","transforms.ValueToKey.fields": "id", "transforms.extractField.type": "org.apache.kafka.connect.transforms.ExtractField$Key", "transforms.extractField.field": "id"} }'  http://localhost:8083/connectors/
