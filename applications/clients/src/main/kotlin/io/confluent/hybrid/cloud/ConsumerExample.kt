@file:JvmName("ConsumerExample")

package io.confluent.hybrid.cloud

import io.confluent.kafka.serializers.KafkaAvroDeserializer
import org.apache.avro.generic.GenericRecord
import org.apache.kafka.clients.consumer.ConsumerConfig.*
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.serialization.StringDeserializer
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import uk.org.webcompere.lightweightconfig.ConfigLoader.loadPropertiesFromResource
import java.time.Duration.ofMillis
import java.util.UUID.randomUUID

private val log: Logger = LoggerFactory.getLogger("ConsumerExample")

fun main() {
    val topic = "customers"
    val props = loadPropertiesFromResource("client.properties")
    props[KEY_DESERIALIZER_CLASS_CONFIG] = StringDeserializer::class.java.name
    props[VALUE_DESERIALIZER_CLASS_CONFIG] = KafkaAvroDeserializer::class.java.name
    props[GROUP_ID_CONFIG] = "confluent_cli_consumer_1${randomUUID()}"
    props[AUTO_OFFSET_RESET_CONFIG] = "earliest"

    val consumer = KafkaConsumer<String, GenericRecord>(props).apply { subscribe(listOf(topic)) }

    consumer.use {
        while (true) {
            consumer.poll(ofMillis(100)).forEach { log.info("${it.value()}") }
        }
    }
}