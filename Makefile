VERSION := $(shell cat VERSION)
TARGETARCH ?= amd64
IMAGE_NAME := docker-agmt
CONTAINER_NAME := test_agmt

HTTP_PORT ?= 6000
HTTPS_PORT ?= 6001

build: stop
# 	docker buildx build --platform linux/amd64 --build-arg VERSION=$(VERSION) --build-arg TARGETARCH=$(TARGETARCH) -t $(IMAGE_NAME) .
	docker build --rm \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE_NAME) .

stop:
	@if [ "$$(docker ps -a --format '{{.Names}}' | grep $(CONTAINER_NAME))" = "$(CONTAINER_NAME)" ]; then \
		docker stop $(CONTAINER_NAME); \
	fi

test: build
	docker run --rm \
		-d --name $(CONTAINER_NAME) \
		-e PUID=1000 \
		-e PGID=1000 \
		-e TZ=Asia/Shanghai \
		-e CUSTOM_PORT=$(HTTP_PORT) \
		-e CUSTOM_HTTPS_PORT=$(HTTPS_PORT) \
		-p $(HTTP_PORT):$(HTTP_PORT) \
		-p $(HTTPS_PORT):$(HTTPS_PORT) \
		$(IMAGE_NAME)

run: test
	@echo "Container $(CONTAINER_NAME) started."
	@echo "Access KasmVNC at http://localhost:$(HTTP_PORT)"

logs:
	docker logs -f $(CONTAINER_NAME)

.PHONY: build stop test run logs