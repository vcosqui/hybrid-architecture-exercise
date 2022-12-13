#!/usr/bin/env bash

podname=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep kafka-connect)
kubectl exec -it "$podname" -- /bin/bash -c "confluent-hub install confluentinc/kafka-connect-jdbc:10.6.0 --no-prompt"