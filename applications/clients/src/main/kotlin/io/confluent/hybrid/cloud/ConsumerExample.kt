@file:JvmName("ConsumerExample")

package io.confluent.hybrid.cloud

import org.apache.avro.generic.GenericRecord
import org.apache.kafka.clients.consumer.ConsumerConfig.GROUP_ID_CONFIG
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.slf4j.Logger
import org.slf4j.LoggerFactory.getLogger
import uk.org.webcompere.lightweightconfig.ConfigLoader.loadPropertiesFromResource
import java.time.Duration.ofMillis
import java.util.UUID.randomUUID

private val log: Logger = getLogger("io.confluent.hybrid.cloud.ConsumerExample")
val topics = listOf("customers", "sellers", "orders", "products")

fun main() {
    val props = loadPropertiesFromResource("client.properties").let {
        it[GROUP_ID_CONFIG] = "confluent_cli_consumer_1${randomUUID()}"
        it
    }
    val consumer = KafkaConsumer<String, GenericRecord>(props).apply { subscribe(topics) }
    consumer.use {
        while (true) {
            consumer.poll(ofMillis(100)).forEach { log.info("[[${it.topic()}]] ${it.value()}") }
        }
    }
}