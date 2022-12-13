#!/usr/bin/env bash

if [[ -z "$TF_VAR_confluent_cloud_api_key" ]]; then
    echo "please, provide TF_VAR_confluent_cloud_api_key in environment" 1>&2
    exit 1
fi
if [[ -z "$TF_VAR_confluent_cloud_api_secret" ]]; then
    echo "please, provide TF_VAR_confluent_cloud_api_secret in environment" 1>&2
    exit 1
fi
if [[ -z "$TF_VAR_confluent_schema_registry_api_key" ]]; then
    echo "please, provide TF_VAR_confluent_schema_registry_api_key in environment" 1>&2
    exit 1
fi
if [[ -z "$TF_VAR_confluent_schema_registry_api_secret" ]]; then
    echo "please, provide TF_VAR_confluent_schema_registry_api_secret in environment" 1>&2
    exit 1
fi

cat <<EOF > .env.ccloud-credentials.txt
username=$TF_VAR_confluent_cloud_api_key
password=$TF_VAR_confluent_cloud_api_secret
EOF
cat <<EOF > .env.ccloud-sr-credentials.txt
username=TF_VAR_confluent_schema_registry_api_key
password=TF_VAR_confluent_schema_registry_api_secret
EOF
cat <<EOF > .env.psql-credentials.txt
connection=jdbc:postgres:5432/merchant?schema=merchant&user=merchant&password=m3rch4nt
EOF

kubectl delete secret ccloud-credentials --ignore-not-found
kubectl create secret generic ccloud-credentials --from-file=plain.txt=.env.ccloud-credentials.txt
rm .env.ccloud-credentials.txt

kubectl delete secret ccloud-sr-credentials --ignore-not-found
kubectl create secret generic ccloud-sr-credentials --from-file=basic.txt=.env.ccloud-sr-credentials.txt
rm .env.ccloud-sr-credentials.txt

kubectl delete secret psql-credentials --ignore-not-found
kubectl create secret generic psql-credentials --from-file=psql-credentials.txt=.env.psql-credentials.txt
rm .env.psql-credentials.txt