package io.confluent.hybrid.cloud.streams

import io.confluent.kafka.streams.serdes.avro.SpecificAvroSerde
import order
import org.apache.kafka.common.serialization.Serdes.String
import org.apache.kafka.common.utils.Bytes
import org.apache.kafka.streams.KafkaStreams
import org.apache.kafka.streams.StreamsBuilder
import org.apache.kafka.streams.StreamsConfig
import org.apache.kafka.streams.kstream.*
import org.apache.kafka.streams.state.KeyValueStore
import pricedOrder
import product
import uk.org.webcompere.lightweightconfig.ConfigLoader
import java.util.*

/**
 * Demonstrates how to perform joins between  KStreams and GlobalKTables, i.e. joins that
 * don't require re-partitioning of the input streams.
 *
 * The [GlobalStoresExample] shows another way to perform the same operation using
 * [org.apache.kafka.streams.TopologyDescription.GlobalStore] and a
 * [org.apache.kafka.streams.kstream.ValueTransformer].
 *
 * In this example, we join a stream of orders that reads from a topic named
 * "order" with a customers table that reads from a topic named "customer", and a products
 * table that reads from a topic "product". The join produces an EnrichedOrder object.
 *
 * HOW TO RUN THIS EXAMPLE
 *
 * If via the command line please refer to [Packaging](https://github.com/confluentinc/kafka-streams-examples#packaging-and-running).
 * Once packaged you can then run:
 * <pre>
 * 7000004#{"id":7000004,"customer_id":"00-000-0003", "items_ordered":"[1000000]",      "order_status":"PROCESSED", "tracking_number":"N/A",        "create_time":"1657973640000"}
 * `$ java -cp target/kafka-streams-examples-7.4.0-0-standalone.jar io.confluent.examples.streams.GlobalKTablesExample
` *
 */
object GlobalKTablesExample {

    const val ORDERS_TOPIC = "orders"
    const val PRODUCTS_TOPIC = "products"
    const val PRODUCTS_STORE = "products-store"
    const val ORDERS_WITH_PRICE_TOPIC = "enriched-order"

    @JvmStatic
    fun main(args: Array<String>) {
        val streams = createStreams()
        streams.cleanUp() // todo: for LOCAL env only
        streams.start()
        Runtime.getRuntime().addShutdownHook(Thread { streams.close() })
    }

    fun createStreams(): KafkaStreams {
        val streamsConfiguration = ConfigLoader.loadPropertiesFromResource("client.properties")
            .also {
//                it[StreamsConfig.APPLICATION_ID_CONFIG] = "streams-orders-with-price"
                it[StreamsConfig.APPLICATION_ID_CONFIG] = "confluent_cli_consumer_1${UUID.randomUUID()}"
                it[StreamsConfig.CLIENT_ID_CONFIG] = "streams-orders-with-price-client"
            }

        // create and configure the SpecificAvroSerdes
        val serdeConfig = streamsConfiguration.toMap() as Map<String, String>
        val orderSerde = SpecificAvroSerde<order>()
        orderSerde.apply { configure(serdeConfig, false) }
        val productSerde = SpecificAvroSerde<product>()
        productSerde.apply { configure(serdeConfig, false) }
        val enrichedOrdersSerde = SpecificAvroSerde<pricedOrder>()
        enrichedOrdersSerde.apply { configure(serdeConfig, false) }

        val builder = StreamsBuilder()

        val ordersStream: KStream<String, order> = builder.stream(ORDERS_TOPIC, Consumed.with(String(), orderSerde))
            .peek { _, v -> System.err.println(v) }

        val productsGlobalKTable: GlobalKTable<String, product> = builder.globalTable(
            PRODUCTS_TOPIC, Materialized.`as`<String, product, KeyValueStore<Bytes, ByteArray>>(
                PRODUCTS_STORE
            ).withKeySerde(String()).withValueSerde(productSerde)
        )

        val productIds: (orderId: String, order: order) -> String = { orderId, order ->
            order.itemsOrdered.replace("[", "").replace("]", "")
            //orderId
            "1000000"
        }
        val pricedOrders: (order: order, product: product) -> pricedOrder = { order, product ->
            System.err.println("sssss")
            pricedOrder(
                order.id,
                order.customerId,
                order.itemsOrdered,
                order.orderStatus,
                order.trackingNumber,
                order.createTime,
                product.productCost
            )
        }
        val pricedOrdersStream: KStream<String, pricedOrder> = ordersStream.join(
            productsGlobalKTable,
            productIds,
            pricedOrders
        )
        pricedOrdersStream.to(ORDERS_WITH_PRICE_TOPIC, Produced.with(String(), enrichedOrdersSerde));
        return KafkaStreams(builder.build(), streamsConfiguration)
    }
}