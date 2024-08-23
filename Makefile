# Variables

REPO=platinumcd
IMAGE_NAME=cfd-dev-image
TAG=1.0.0

IMAGE_URI=$(REPO)/$(IMAGE_NAME):$(TAG)
IMAGE_URI_LATEST=$(REPO)/$(IMAGE_NAME):latest

# Build the Docker image
build:
	docker build -t $(IMAGE_URI) .

run:
	docker run -it $(IMAGE_URI)

# Push the Docker image to the registry
push: build
	docker image tag $(IMAGE_URI) $(IMAGE_URI_LATEST)
	docker push $(IMAGE_URI_LATEST)
	docker push $(IMAGE_URI)

# Remove the Docker image locally
clean:
	docker rmi $(IMAGE_URI)

.PHONY: build push clean
