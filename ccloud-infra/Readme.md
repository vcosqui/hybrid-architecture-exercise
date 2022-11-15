
### verify cluster schema validation
```shell
terraform apply -auto-approve

# manually create schema registry key

terraform apply -auto-approve

terraform output resource-ids

confluent kafka topic produce user_added --parse-key --delimiter "#" --environment env-v7o9n0 --cluster lkc-pgyz3y --api-key "MQG2VS4WXMIHAOOV" --api-secret "hGJx9tCwbqg0/h2hZ7cHb7W06ZTd6tfny7JNZRFQVMrMs19Xk9tqZ1XCJukIdgpC" --value-format avro --schema-id=100001 --sr-api-key="EPE2RPHMEUB3EY5I" --sr-api-secret="ujpLF6srUMlNViYBXrR62irUL+H0EcwBGsD9SzMPEEOJLBrXq6fewSQC8y0a2wFB"
# Starting Kafka Producer. Use Ctrl-C or Ctrl-D to exit.
# 1#{"foo":"bvar"}
# 2#{"foo":"tar"}
# 3#{"foo":"nar"}
# 4#{"foo":"har"}
# 5#{"foo":"jar"}
# 6#{"foo":"aar"}
# 7#{"foo":"","too":""}
# Error: cannot decode textual record "sampleRecord": cannot decode textual map: cannot determine codec: "too"
```