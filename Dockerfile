FROM ubuntu:24.04

ARG TARGETOS
ARG TARGETARCH

EXPOSE 9443
EXPOSE 9000
EXPOSE 8000

USER root

# Set TERM as noninteractive to suppress debconf errors
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Set default go version
ARG GO_VERSION=go1.22.8.${TARGETOS}-${TARGETARCH}

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
	dialog \
	apt-utils \
	curl \
	build-essential \
	git \
	jq \
	wget \
	apt-transport-https \
	ca-certificates \
	gnupg-agent \
	libarchive-tools \
	openssh-client \
	iputils-ping \
	nano \
	software-properties-common \
	&& rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
	&& add-apt-repository \
	"deb [arch=${TARGETARCH}] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable" \
	&& apt-get update \
	&& apt-get install -y docker-ce-cli

# Install docker compose plugin
RUN mkdir -p /root/.docker/cli-plugins/ && \
	if [ "$TARGETARCH" = "amd64" ]; then \
		COMPOSE_ARCH="x86_64"; \
	elif [ "$TARGETARCH" = "arm64" ]; then \
		COMPOSE_ARCH="aarch64"; \
	else \
		echo "Unsupported architecture: $TARGETARCH" >&2; \
		exit 1; \
	fi && \
	curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${COMPOSE_ARCH}" -o /root/.docker/cli-plugins/docker-compose && \
	chmod +x /root/.docker/cli-plugins/docker-compose

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
	&& apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& apt-get update && apt-get -y install yarn

# Install Golang
RUN cd /tmp \
	&& wget -q https://dl.google.com/go/${GO_VERSION}.tar.gz \
	&& tar -xf ${GO_VERSION}.tar.gz \
	&& mv go /usr/local

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /root/go/bin v1.61.0

# Configuring Golang
ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"
