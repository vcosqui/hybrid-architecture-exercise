terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.13.0"
    }
    schemaregistry = {
      source = "arkiaconsulting/confluent-schema-registry"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_environment" "dev" {
  display_name = "dev"
}

# Stream Governance and Kafka clusters can be in different regions as well as different cloud providers,
# but you should to place both in the same cloud and region to restrict the fault isolation boundary.
data "confluent_stream_governance_region" "essentials" {
  cloud   = "GCP"
  region  = "us-central1"
  package = "ESSENTIALS"
}

resource "confluent_stream_governance_cluster" "essentials" {
  package = data.confluent_stream_governance_region.essentials.package

  environment {
    id = confluent_environment.dev.id
  }

  region {
    # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#stream-governance-regions
    id = data.confluent_stream_governance_region.essentials.id
  }
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "standard" {
  display_name = "dev"
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       = "us-central1"
  dedicated {
    cku = 1
  }
  environment {
    id = confluent_environment.dev.id
  }
}

// 'app-manager' service account is required in this configuration to create topics and assign roles
// to 'app-producer' and 'app-consumer' service accounts.
resource "confluent_service_account" "app-manager" {
  display_name = "app-manager"
  description  = "Service account to manage 'dev' Kafka cluster"
}

resource "confluent_service_account" "connect-1" {
  display_name = "connect"
  description  = "Connect service account"
}

resource "confluent_service_account" "connect-1-1" {
  display_name = "connect1"
  description  = "Connect service account"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind

    environment {
      id = confluent_environment.dev.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

resource "confluent_kafka_topic" "orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "orders"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact" # topic key is order_id
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "sellers" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "sellers"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact" # topic key is seller_id
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "customers" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "customers"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact" # topic key is customer_id
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "products" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "products"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # server schema validation
    "cleanup.policy"                    = "compact" # topic key is product_id
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "priced_orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "priced_orders"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact" # topic key is order_id
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "connect-cp-kafka-connect-offset" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "default.connect-offsets"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "connect-cp-kafka-connect-status" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "default.connect-status"
  partitions_count = 6
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "connect-cp-kafka-connect-config" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name       = "default.connect-configs"
  partitions_count = 1
  rest_endpoint    = confluent_kafka_cluster.standard.rest_endpoint
  config           = {
    "retention.ms"                      = "-1"      # keep forever
    "confluent.value.schema.validation" = true      # broker schema validation
    "cleanup.policy"                    = "compact"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_service_account" "app-consumer" {
  display_name = "app-consumer"
  description  = "Service account to consume from 'orders', 'sellers', 'customers', 'products', 'priced_orders' topics of 'dev' Kafka cluster"
}

resource "confluent_api_key" "app-consumer-kafka-api-key" {
  display_name = "app-consumer-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-consumer' service account"
  owner {
    id          = confluent_service_account.app-consumer.id
    api_version = confluent_service_account.app-consumer.api_version
    kind        = confluent_service_account.app-consumer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind

    environment {
      id = confluent_environment.dev.id
    }
  }
}

resource "confluent_role_binding" "app-producer-orders-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.orders.topic_name}"
}

resource "confluent_role_binding" "app-producer-sellers-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.sellers.topic_name}"
}

resource "confluent_role_binding" "app-producer-customers-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.customers.topic_name}"
}

resource "confluent_role_binding" "app-producer-products-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.products.topic_name}"
}

resource "confluent_role_binding" "app-producer-priced-orders-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.priced_orders.topic_name}"
}

resource "confluent_role_binding" "app-producer-connect-cp-kafka-connect-offset-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-offset.topic_name}"
}

resource "confluent_role_binding" "app-producer-connect-cp-kafka-connect-status-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-status.topic_name}"
}

resource "confluent_role_binding" "app-producer-connect-cp-kafka-connect-config-developer-write" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-config.topic_name}"
}


resource "confluent_service_account" "app-producer" {
  display_name = "app-producer"
  description  = "account to produce to 'orders', 'sellers', 'customers', 'products', 'priced_orders', 'connect-cp-kafka-connect-*'"
}

resource "confluent_api_key" "app-producer-kafka-api-key-v2" {
  display_name = "app-producer-kafka-api-key-v2"
  description  = "Kafka API Key that is owned by 'app-producer' service account"
  owner {
    id          = confluent_service_account.app-producer.id
    api_version = confluent_service_account.app-producer.api_version
    kind        = confluent_service_account.app-producer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind

    environment {
      id = confluent_environment.dev.id
    }
  }
}

// Note that in order to consume from a topic, the principal of the consumer ('app-consumer' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
resource "confluent_role_binding" "app-producer-developer-orders-read-from-topic" {
  principal   = "User:${confluent_service_account.app-consumer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.orders.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-sellers-read-from-topic" {
  principal   = "User:${confluent_service_account.app-consumer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.sellers.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-customers-read-from-topic" {
  principal   = "User:${confluent_service_account.app-consumer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.customers.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-products-read-from-topic" {
  principal   = "User:${confluent_service_account.app-consumer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.products.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-priced-orders-read-from-topic" {
  principal   = "User:${confluent_service_account.app-consumer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.priced_orders.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-connect-cp-kafka-connect-offset-read-from-topic" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-offset.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-connect-cp-kafka-connect-status-read-from-topic" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-status.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-connect-cp-kafka-connect-config-read-from-topic" {
  principal   = "User:${confluent_service_account.app-producer.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-config.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-read-from-group" {
  principal   = "User:${confluent_service_account.app-consumer.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=confluent_cli_consumer_*"
}

resource "confluent_role_binding" "app-connect-read-from-group-c" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=connect-consumer-group"
}

resource "confluent_role_binding" "app-connect-read-from-group-c-all" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=*"
}

#resource "confluent_role_binding" "app-connect-read-from-group-c-all-star" {
#  principal   = "User:*"
#  role_name   = "ResourceOwner"
#  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
#  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
#  // Update it to match your target consumer group ID.
#  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=default.connect"
#}


resource "confluent_role_binding" "app-connect-read-from-group-c-all-star-n" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=default.connect"
}

resource "confluent_role_binding" "app-connect-read-from-group-c-all-ResourceOwner" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=*"
}

resource "confluent_role_binding" "app-connect-read-from-group" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=connect*"
}

resource "confluent_role_binding" "app-connect-read-from-group-cc" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=consumer*"
}

// Note that in order to consume from a topic, the principal of the consumer ('app-consumer' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
resource "confluent_role_binding" "app-producer-developer-orders-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.orders.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-sellers-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.sellers.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-customers-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.customers.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-products-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.products.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-priced-orders-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.priced_orders.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-connect-cp-kafka-connect-offset-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-offset.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-connect-cp-kafka-connect-status-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-status.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-connect-cp-kafka-connect-config-read-from-topic-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.connect-cp-kafka-connect-config.topic_name}"
}

resource "confluent_role_binding" "app-producer-developer-read-from-group-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=confluent_cli_consumer_*"
}

resource "confluent_role_binding" "app-connect-read-from-group-connect" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=connect*"
}

resource "confluent_role_binding" "app-connect-read-from-group-connect-cc" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=consumer*"
}


resource "confluent_role_binding" "app-connect-read-from-group-connect-c" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=connect-consumer-group"
}

resource "confluent_role_binding" "app-connect-read-from-group-connect-c-all" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=*"
}

resource "confluent_role_binding" "app-connect-read-from-group-connect-c-all-ResourceOwner" {
  principal   = "User:${confluent_service_account.connect-1.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/group=*"
}

// schema registry
provider "schemaregistry" {
  schema_registry_url = var.confluent_schema_registry_url
  username            = var.confluent_schema_registry_api_key
  password            = var.confluent_schema_registry_api_secret
}

resource "schemaregistry_schema" "customer" {
  # server will use to validate customers topic events
  subject = "customers-value"
  schema  = file("./schemas/customer.avsc")
}

data "schemaregistry_schema" "customer" {
  subject = schemaregistry_schema.customer.subject
}

resource "schemaregistry_schema" "seller" {
  # server will use to validate sellers topic events
  subject = "sellers-value"
  schema  = file("./schemas/seller.avsc")
}

data "schemaregistry_schema" "seller" {
  subject = schemaregistry_schema.seller.subject
}

resource "schemaregistry_schema" "product" {
  # server will use to validate products topic events
  subject = "products-value"
  schema  = file("./schemas/product.avsc")
}

data "schemaregistry_schema" "product" {
  subject = schemaregistry_schema.product.subject
}

resource "schemaregistry_schema" "order" {
  # server will use to validate orders topic events
  subject = "orders-value"
  schema  = file("./schemas/order.avsc")
}

data "schemaregistry_schema" "order" {
  subject = schemaregistry_schema.order.subject
}

resource "schemaregistry_schema" "priced-order" {
  # server will use to validate priced_orders topic events
  subject = "priced-orders-value"
  schema  = file("./schemas/priced_order.avsc")
}

data "schemaregistry_schema" "priced-order" {
  subject = schemaregistry_schema.priced-order.subject
}

# -------------- kSql cluster --------------------

resource "confluent_service_account" "ksql" {
  display_name = "ksql-service-account"
  description  = "Service account to manage ksqlDB cluster"
}

resource "confluent_role_binding" "app-ksql-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.ksql.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

#resource "confluent_ksql_cluster" "ksql-cluster" {
#  display_name = "ksql"
#  csu          = 1
#  kafka_cluster {
#    id = confluent_kafka_cluster.standard.id
#  }
#  credential_identity {
#    id = confluent_service_account.ksql.id
#  }
#  environment {
#    id = confluent_environment.dev.id
#  }
#  depends_on = [
#    confluent_role_binding.app-ksql-kafka-cluster-admin,
#    confluent_stream_governance_cluster.essentials
#  ]
#}
#
#resource "null_resource" "example1" {
#  provisioner "local-exec" {
#    command = "echo '\n\n-= HEY GO DO THAT MANUAL THINGY THEN RUN `touch /tmp/ididit`; I WILL WAIT HERE =-\n\n'; while ! test -f /tmp/ididit; do sleep 1; done"
#  }
#}
#resource "null_resource" "example2" {
#  provisioner "local-exec" {
#    command = "echo 'thanks!'"
#  }
#  depends_on = [null_resource.example1]
#}