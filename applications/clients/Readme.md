
# Example clients

Some clients consuming events.

## Setup

Configure client secrets.

Create an env file exporting all the needed variables 
```shell
cat <<EOF >>.env
export CLUSTER_URL="xxxxxxxxxxxxxxxx"
export CLUSTER_API_KEY="xxxxxxxxxxxxxxxx"
export CLUSTER_API_SECRET="xxxxxxxxxxxxxxxx"
export TF_VAR_confluent_schema_registry_url="xxxxxxxxxxxxxxxx"
export TF_VAR_confluent_schema_registry_api_key="xxxxxxxxxxxxxxxx"
export TF_VAR_confluent_schema_registry_api_secret="xxxxxxxxxxxxxxxx"
EOF
```
Then apply it to your shell session
```shell
source .env 
```

## Download schemas from Schema Registry
```shell
make download-avro-schemas
```

## Build the app and run consumer
```shell
make avro-consumer
```

## More help
Run
```shell
make
```