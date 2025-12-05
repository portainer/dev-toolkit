# Note: these can be overriden on the command line e.g. `make VERSION=2025.09`
VERSION=2025.09

.PHONY: base-amd64 base-arm64 base alapenna alapenna-ghostty

base-amd64:
	docker build --push --platform=linux/amd64 -t portainer/dev-toolkit:$(VERSION)-amd64 -f Dockerfile .

base-arm64:
	docker build --push --platform=linux/arm64 -t portainer/dev-toolkit:$(VERSION)-arm64 -f Dockerfile .

# Note: buildx sucks for multi-arch: https://skyworkz.nl/blog/multi-arch-docker-image-10x-faster
base: base-amd64 base-arm64
	docker manifest create \
		portainer/dev-toolkit:$(VERSION) \
		portainer/dev-toolkit:$(VERSION)-amd64 \
		portainer/dev-toolkit:$(VERSION)-arm64
	docker manifest push portainer/dev-toolkit:$(VERSION)

alapenna:
	docker build --platform=linux/arm64 -t portainer-dev-toolkit:alapenna -f user-toolkits/alapenna/Dockerfile .

alapenna-ghostty:
	docker build --platform=linux/arm64 -t portainer-dev-toolkit:alapenna-ghostty -f user-toolkits/alapenna-ghostty/Dockerfile .
