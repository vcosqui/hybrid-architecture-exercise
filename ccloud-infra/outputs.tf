output "resource-ids" {
  value = <<-EOT
  Environment ID:   ${confluent_environment.dev.id}
  Kafka Cluster ID: ${confluent_kafka_cluster.standard.id}
  Kafka topic name: ${confluent_kafka_topic.orders.topic_name}
  Service Accounts and their Kafka API Keys (API Keys inherit the permissions granted to the owner):
  ${confluent_service_account.app-manager.display_name}:                     ${confluent_service_account.app-manager.id}
  ${confluent_service_account.app-manager.display_name}'s Kafka API Key:     "${confluent_api_key.app-manager-kafka-api-key.id}"
  ${confluent_service_account.app-manager.display_name}'s Kafka API Secret:  "${confluent_api_key.app-manager-kafka-api-key.secret}"
  ${confluent_service_account.app-producer.display_name}:                    ${confluent_service_account.app-producer.id}
  ${confluent_service_account.app-producer.display_name}'s Kafka API Key:    "${confluent_api_key.app-producer-kafka-api-key.id}"
  ${confluent_service_account.app-producer.display_name}'s Kafka API Secret: "${confluent_api_key.app-producer-kafka-api-key.secret}"
  ${confluent_service_account.app-consumer.display_name}:                    ${confluent_service_account.app-consumer.id}
  ${confluent_service_account.app-consumer.display_name}'s Kafka API Key:    "${confluent_api_key.app-consumer-kafka-api-key.id}"
  ${confluent_service_account.app-consumer.display_name}'s Kafka API Secret: "${confluent_api_key.app-consumer-kafka-api-key.secret}"
  In order to use the Confluent CLI v2 to produce and consume messages from topic '${confluent_kafka_topic.orders.topic_name}' using Kafka API Keys
  of ${confluent_service_account.app-producer.display_name} and ${confluent_service_account.app-consumer.display_name} service accounts
  run the following commands:
  # 1. Log in to Confluent Cloud
  $ confluent login
  # 2. Produce key-value records to topic '${confluent_kafka_topic.orders.topic_name}' by using ${confluent_service_account.app-producer.display_name}'s Kafka API Key
  $ confluent kafka topic produce ${confluent_kafka_topic.orders.topic_name} --parse-key --delimiter # --environment ${confluent_environment.dev.id} --cluster ${confluent_kafka_cluster.standard.id} --api-key "${confluent_api_key.app-producer-kafka-api-key.id}" --api-secret "${confluent_api_key.app-producer-kafka-api-key.secret}"
  $ ##########################################################################
  $ confluent kafka topic produce ${confluent_kafka_topic.customers.topic_name} --parse-key --delimiter '#' \
--environment ${confluent_environment.dev.id} --cluster ${confluent_kafka_cluster.standard.id} \
--api-key "${confluent_api_key.app-producer-kafka-api-key.id}" --api-secret "${confluent_api_key.app-producer-kafka-api-key.secret}" \
--sr-api-key="${var.confluent_schema_registry_api_key}" --sr-api-secret="${var.confluent_schema_registry_api_secret}" \
--value-format avro --schema-id=${data.schemaregistry_schema.customer.schema_id}
  $ ##########################################################################
  # Enter a few records and then press 'Ctrl-C' when you're done.
  # Sample records: (Message Key is the customerId)
  # 1#{"number":1,"customerId":1,"date":18500,"shipping_address":"899 W Evelyn Ave, Mountain View, CA 94041, USA","cost":15.00}
  # 1#{"number":2,"customerId":1,"date":18501,"shipping_address":"1 Bedford St, London WC2E 9HG, United Kingdom","cost":5.00}
  # 2#{"number":3,"customerId":2,"date":18502,"shipping_address":"3307 Northland Dr Suite 400, Austin, TX 78731, USA","cost":10.00}
  # 3#{"number":1,"customerId":3,"date":18503,"shipping_address":"Helm st., Springfield, VA 22345, USA","cost":35.50}
  # 4#{"number":2,"customerId":4,"date":18504,"shipping_address":"Niederrheinallee 335, Neukirchen-Vluyn, Germany","cost":5.00}
  # 5#{"number":3,"customerId":5,"date":18505,"shipping_address":"67 Nan'an Rd, 荔湾区, China","cost":67.00}
  # 6#{"number":3,"customerId":6,"date":18506,"shipping_address":"Uke St, 900211, Abuja, Nigeria","cost":120.00}
  # 3. Consume records from topic '${confluent_kafka_topic.orders.topic_name}' by using ${confluent_service_account.app-consumer.display_name}'s Kafka API Key
  $ confluent kafka topic consume ${confluent_kafka_topic.orders.topic_name} --print-key --from-beginning --environment ${confluent_environment.dev.id} --cluster ${confluent_kafka_cluster.standard.id} --api-key "${confluent_api_key.app-consumer-kafka-api-key.id}" --api-secret "${confluent_api_key.app-consumer-kafka-api-key.secret}"
  # When you are done, press 'Ctrl-C'.
  EOT

  sensitive = true
}
#
#output "schema-registry" {
#  value = <<-EOT
#  Schema Registry [user_added] ID:   ${data.schemaregistry_schema.user_added.id}
#  Schema Registry [user_added] ID:   ${data.schemaregistry_schema.user_added.version}
#  Schema Registry [user_added] ID:   ${data.schemaregistry_schema.user_added.schema_id}
#  EOT
#
#  sensitive = true
#}


##confluent kafka topic produce user_added2 --parse-key --delimiter "#" --environment env-j5d728 --cluster lkc-v7g02p --api-key "4EETIYU52BRE2LC5" --api-secret "T4m95VzRHKjsM+nrN0rFHKwYZWYuCME3qwUmJjMt1aR++AoyvB3dycW4J1B4wFMm" --value-format avro --schema-id=100003 --sr-api-key="TE6O3Z4YHFRI4Z3Y" --sr-api-secret="4/aJidRl83S4/yIbDfW7Fhak4+o2+gPJhMnVrP1Z28qDklJjsM92r2G2TdxlH6iE"
# 1#{"foo":"bar"}