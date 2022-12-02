#!/usr/bin/env bash

if [[ -z "$TF_VAR_confluent_cloud_api_key" ]]; then
    echo "please, provide TF_VAR_confluent_cloud_api_key in environment" 1>&2
    exit 1
fi
if [[ -z "$TF_VAR_confluent_cloud_api_secret" ]]; then
    echo "please, provide TF_VAR_confluent_cloud_api_secret in environment" 1>&2
    exit 1
fi

kubectl delete secret cc-broker-credentials --ignore-not-found
kubectl create secret generic cc-broker-credentials --save-config \
--from-literal=username="$TF_VAR_confluent_cloud_api_key" \
--from-literal=password="$TF_VAR_confluent_cloud_api_secret"


if [[ -z "$TF_VAR_confluent_schema_registry_api_key" ]]; then
    echo "please, provide TF_VAR_confluent_schema_registry_api_key in environment" 1>&2
    exit 1
fi
if [[ -z "$TF_VAR_confluent_schema_registry_api_secret" ]]; then
    echo "please, provide TF_VAR_confluent_schema_registry_api_secret in environment" 1>&2
    exit 1
fi

kubectl delete secret cc-sr-credentials --ignore-not-found
kubectl create secret generic cc-sr-credentials --save-config \
--from-literal=username="$TF_VAR_confluent_schema_registry_api_key" \
--from-literal=password="$TF_VAR_confluent_schema_registry_api_secret"
