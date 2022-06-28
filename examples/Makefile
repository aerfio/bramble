.PHONY: all
all: container-images kind-start kind-load-images apply-resources

.PHONY: docker-%
docker-%:
	cd "$*" && docker buildx build -t "$*:latest" .

.PHONY: container-images
container-images: docker-gqlgen-service docker-graph-gophers-service docker-nodejs-service

.PHONY: kind-start
kind-start:
	./kind-ingress.sh

.PHONY: kind-load-images
kind-load-images:
	kind load docker-image gqlgen-service:latest graph-gophers-service:latest nodejs-service:latest

.PHONY: apply-resources
apply-resources:
	jsonnet -y ./resources.jsonnet | kubectl apply -f -
