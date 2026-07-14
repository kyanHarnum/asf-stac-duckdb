SHELL := /bin/bash

.DEFAULT_GOAL := help

AWS_DEFAULT_REGION ?= us-west-2
AWS_DEFAULT_PROFILE ?= default
STACK_NAME ?= duck-stac

## COLLECTION ?= glo-30-hand // testing purposes

.PHONY: ingest
ingest: 
	cd collections/$(COLLECTION) && \
	python3 -m venv venv && \
	. venv/bin/activate && \
	pip install -e ../../asf-stac-util && \
	pip install -r ../../duck-stac/requirements.txt && \
	chmod +x ./list-objects && \
	./list-objects && \
	wc -l objects.txt && \
	python create_items.py objects.txt > items.ndjson && \
	head -n 5 items.ndjson

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*##"} {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

build: ## Build SAM app
	cd duck-stac && sam build

local: ## Run SAM local development server
	cd duck-stac && \
	sam local start-api \
  		--env-vars lambda-env.json \
		--region $(AWS_DEFAULT_REGION) \
		--profile $(AWS_DEFAULT_PROFILE)

deploy: build ## Build and deploy SAM app
	cd duck-stac && \
	sam deploy \
		--stack-name=$(STACK_NAME) \
		--no-confirm-changeset \
		--no-fail-on-empty-changeset \
		--region $(AWS_DEFAULT_REGION) \
		--profile $(AWS_DEFAULT_PROFILE)

sam-image: ## Create a sam docker image
	docker build -t sam-runner -f sam.Dockerfile .

shell: sam-image ## Run SAM inside container
	docker run -it \
		-v .:/sam/ \
		-v $$HOME/.aws/:/root/.aws \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e STACK_NAME \
		-e AWS_DEFAULT_REGION \
		-e AWS_DEFAULT_PROFILE \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_SESSION_TOKEN \
		sam-runner /bin/bash

#what the makefile does:
#build: builds the sam app
#local: runs the sam app locally
#deploy: builds and deploys the sam app to AWS
#aws: runs the sam app in a docker container with aws credentials
#starts