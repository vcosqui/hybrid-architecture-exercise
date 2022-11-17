import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

group = "io.confluent.hybrid.cloud"

configurations.all {
    resolutionStrategy {
        force("io.confluent:kafka-schema-registry-client:7.2.2")
    }
}

buildscript {
    repositories {
        jcenter()
        maven("https://plugins.gradle.org/m2/")
        maven("https://packages.confluent.io/maven/")
        mavenCentral()
    }
    dependencies {
        classpath("com.github.imflog:kafka-schema-registry-gradle-plugin:1.8.0")
        classpath("io.confluent:kafka-schema-registry-parent:7.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
    }
}

repositories {
    jcenter()
    maven(url = "https://packages.confluent.io/maven/")
    maven(url = "https://plugins.gradle.org/m2/")
    mavenCentral()
}

plugins {
    java
    kotlin("jvm") version "1.4.20"
    id("com.github.imflog.kafka-schema-registry-gradle-plugin") version "1.8.0"
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

dependencies {

    implementation(kotlin("stdlib"))
    implementation(kotlin("reflect"))

    implementation("org.apache.kafka:kafka-clients:3.3.1")
    implementation("org.apache.kafka:kafka-streams:3.3.1")
    implementation("org.apache.kafka:connect-runtime:3.3.1")
    implementation("io.confluent:kafka-avro-serializer:5.3.0")
    implementation("org.slf4j:slf4j-api:2.0.3")
    implementation("org.slf4j:slf4j-log4j12:2.0.3")
    implementation("uk.org.webcompere:lightweight-config:1.2.0")
    implementation("com.github.imflog:kafka-schema-registry-gradle-plugin:1.8.0")
}

tasks.withType<KotlinCompile> {
    kotlinOptions.jvmTarget = "1.8"
}

task("runConsumer", JavaExec::class) {
    classpath = sourceSets["main"].runtimeClasspath
    main = "io.confluent.hybrid.cloud.ConsumerExample"
}

schemaRegistry {
    url.set("${System.getenv("TF_VAR_confluent_schema_registry_url")}")
    credentials {
        username.set("${System.getenv("TF_VAR_confluent_schema_registry_api_key")}")
        password.set("${System.getenv("TF_VAR_confluent_schema_registry_api_secret")}")
    }
    download {
        subject("customers-value", "schemas/avro")
        subject("orders-value", "schemas/avro")
        subject("products-value", "schemas/avro")
        subject("sellers-value", "schemas/avro")
    }
}