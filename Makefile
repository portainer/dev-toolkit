# Note: these can be overriden on the command line e.g. `make VERSION=2023.03`
VERSION=2023.03

.PHONY: setup clean base alapenna

setup:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multiarch --driver docker-container --use
	docker buildx inspect --bootstrap

clean:
	docker buildx rm multiarch

base: setup
	docker buildx build --push --platform=linux/arm64,linux/amd64 -t portainer/dev-toolkit:$(VERSION) -f Dockerfile .

alapenna:
	docker buildx build --no-cache --load -t portainer-dev-toolkit -f user-toolkits/alapenna/Dockerfile .
