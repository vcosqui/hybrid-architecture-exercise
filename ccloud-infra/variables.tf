variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_schema_registry_url" {
  description = "Confluent Schema Registry URL"
  type        = string
  sensitive   = true
}

variable "confluent_schema_registry_api_key" {
  description = "Confluent Schema Registry API key"
  type        = string
  sensitive   = true
}

variable "confluent_schema_registry_api_secret" {
  description = "Confluent Schema API secret"
  type        = string
  sensitive   = true
}
