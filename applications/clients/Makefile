.PHONY: consumer build download-avro-schemas help

.DEFAULT_GOAL := help

## ┌───────────────────────────────────────────────────────────────────┐
## │                       Example Makefile                            │
## │ ───────────────────────────────────────────────────────────────── │
## │ Example commands: "make build" or "make consumer"                 │
## └───────────────────────────────────────────────────────────────────┘

consumer: ## Run consumer for input queues
	@:$(call check_defined, CLUSTER_URL, Broker URL)
	@:$(call check_defined, CLUSTER_API_KEY, Broker username)
	@:$(call check_defined, CLUSTER_API_SECRET, Broker password)
	./gradlew clean build runConsumer

build: ## Compile program
	./gradlew clean build

download-avro-schemas: ## Download AVRO schemas
	@:$(call check_defined, TF_VAR_confluent_schema_registry_url, Schema registry URL)
	@:$(call check_defined, TF_VAR_confluent_schema_registry_api_key, Schema registry API key)
	@:$(call check_defined, TF_VAR_confluent_schema_registry_api_secret, Schema registry API secret)
	./gradlew downloadSchemasTask

help: ## show this help
	@sed -ne "s/^##\(.*\)/\1/p" $(MAKEFILE_LIST)
	@printf "────────────────────────`tput bold``tput setaf 2` Make Commands `tput sgr0`────────────────────────────────\n"
	@sed -ne "/@sed/!s/\(^[^#?=]*:\).*##\(.*\)/`tput setaf 2``tput bold`\1`tput sgr0`\2/p" $(MAKEFILE_LIST)
	@printf "────────────────────────`tput bold``tput setaf 4` Make Variables `tput sgr0`───────────────────────────────\n"
	@sed -ne "/@sed/!s/\(.*\)?=\(.*\)##\(.*\)/`tput setaf 4``tput bold`\1:`tput setaf 5`\2`tput sgr0`\3/p" $(MAKEFILE_LIST)
	@printf "───────────────────────────────────────────────────────────────────────\n"

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Undefined $1$(if $2, ($2))$(if $(value @), \
                required by target `$@')))