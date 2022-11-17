//@file:JvmName("ProducerExample")
//
//package io.confluent.hybrid.cloud
//
//import org.apache.avro.generic.GenericRecord
//import org.apache.kafka.clients.consumer.ConsumerConfig.GROUP_ID_CONFIG
//import org.apache.kafka.clients.consumer.KafkaConsumer
//import org.slf4j.LoggerFactory.getLogger
//import uk.org.webcompere.lightweightconfig.ConfigLoader.loadPropertiesFromResource
//import java.time.Duration.ofMillis
//import java.util.UUID.randomUUID
//
//private val log = getLogger("io.confluent.hybrid.cloud.ProducerExample")
//private val topics = listOf("customers", "sellers", "orders", "products")
//
//fun main() {
//    val props = loadPropertiesFromResource("client.properties")
//        .also { it[GROUP_ID_CONFIG] = "confluent_cli_consumer_1${randomUUID()}" }
//
//}


//import io.confluent.examples.clients.cloud.model.DataRecord
//import org.apache.kafka.clients.admin.AdminClient
//import org.apache.kafka.clients.admin.NewTopic
//import org.apache.kafka.clients.producer.KafkaProducer
//import org.apache.kafka.clients.producer.ProducerConfig.*
//import org.apache.kafka.clients.producer.ProducerRecord
//import org.apache.kafka.clients.producer.RecordMetadata
//import org.apache.kafka.common.errors.TopicExistsException
//import org.apache.kafka.common.serialization.StringSerializer
//import java.util.*
//import java.util.concurrent.ExecutionException
//import kotlin.system.exitProcess
//

//    // Add additional properties.
//    props[ACKS_CONFIG] = "all"
//    props[KEY_SERIALIZER_CLASS_CONFIG] = StringSerializer::class.qualifiedName
////    props[VALUE_SERIALIZER_CLASS_CONFIG] = KafkaJsonSerializer::class.qualifiedName
//
//    // Produce sample data
//    val numMessages = 10
//    // `use` will execute block and close producer automatically
//    KafkaProducer<String, DataRecord>(props).use { producer ->
//        repeat(numMessages) { i ->
//            val key = "alice"
//            val record = DataRecord(i.toLong())
//            println("Producing record: $key\t$record")
//
//            producer.send(ProducerRecord(topic, key, record)) { m: RecordMetadata, e: Exception? ->
//                when (e) {
//                    // no exception, good to go!
//                    null -> println("Produced record to topic ${m.topic()} partition [${m.partition()}] @ offset ${m.offset()}")
//                    // print stacktrace in case of exception
//                    else -> e.printStackTrace()
//                }
//            }
//        }
//
//        producer.flush()
//        println("10 messages were produced to topic $topic")
//    }
//
//}
