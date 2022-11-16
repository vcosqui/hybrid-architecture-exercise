import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

group = "io.confluent.hybrid.cloud"

plugins {
    java
    kotlin("jvm") version "1.4.20"
}

java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

dependencies {
    compile(kotlin("stdlib"))
    compile(kotlin("reflect"))

    compile("org.apache.kafka:kafka-clients:3.3.1")
    compile("org.apache.kafka:kafka-streams:3.3.1")
    compile("org.apache.kafka:connect-runtime:3.3.1")
    implementation("io.confluent:kafka-avro-serializer:5.3.0")
    compile("org.slf4j:slf4j-api:2.0.3")
    compile("org.slf4j:slf4j-log4j12:2.0.3")
    implementation("uk.org.webcompere:lightweight-config:1.2.0")
}

repositories {
    jcenter()
    maven(url = "https://packages.confluent.io/maven/")
    mavenCentral()
}

tasks.withType<KotlinCompile> {
    kotlinOptions.jvmTarget = "1.8"
}

task("runConsumer", JavaExec::class) {
    classpath = sourceSets["main"].runtimeClasspath
    main = "io.confluent.hybrid.cloud.ConsumerExample"
}
