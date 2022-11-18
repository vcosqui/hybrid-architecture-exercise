@file:JvmName("AVROConsumerExample")

package io.confluent.hybrid.cloud

import customer
import org.apache.kafka.clients.consumer.ConsumerConfig.GROUP_ID_CONFIG
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.slf4j.LoggerFactory.getLogger
import uk.org.webcompere.lightweightconfig.ConfigLoader.loadPropertiesFromResource
import java.time.Duration.ofMillis
import java.util.UUID.randomUUID

private val log = getLogger("io.confluent.hybrid.cloud.AVROConsumerExample")
private val topics = listOf("customers")

fun main() {
    val props = loadPropertiesFromResource("client.properties")
        .also { it[GROUP_ID_CONFIG] = "confluent_cli_consumer_1${randomUUID()}" }

    val consumer = KafkaConsumer<String, customer>(props).apply { subscribe(topics) }
    consumer.use {
        while (true) {
            consumer.poll(ofMillis(100)).forEach { log.info("${it.value()}") }
        }
    }
}