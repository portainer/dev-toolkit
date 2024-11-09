FROM ubuntu:24.04

ARG TARGETOS
ARG TARGETARCH
ARG GO_VERSION=1.23.2
ARG GOLANGCI_LINT_VERSION=v1.61.0
ARG DOCKER_VERSION=27.3.1
ARG DOCKER_COMPOSE_VERSION=2.30.0
ARG NODE_VERSION=18.20.4
ARG YARN_VERSION=1.22.22

EXPOSE 8000 8999 9000 9443

USER root

# Set TERM as noninteractive to suppress debconf errors
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base packages and utilities
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

# Install Docker CLI & Docker Compose Plugin
ARG DOCKER_PACKAGE=5:${DOCKER_VERSION}-1~ubuntu.24.04~noble
ARG DOCKER_COMPOSE_PACKAGE=${DOCKER_COMPOSE_VERSION}-1~ubuntu.24.04~noble
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli=${DOCKER_PACKAGE} docker-compose-plugin=${DOCKER_COMPOSE_PACKAGE}

# Install Golang
ARG GO_PACKAGE=go${GO_VERSION}.${TARGETOS}-${TARGETARCH}
RUN cd /tmp \
	&& wget -q https://dl.google.com/go/${GO_PACKAGE}.tar.gz \
	&& tar -xf ${GO_PACKAGE}.tar.gz \
	&& mv go /usr/local

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /root/go/bin ${GOLANGCI_LINT_VERSION}

# Install NodeJS
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION}

# Install Yarn
RUN PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}" npm install --global yarn@${YARN_VERSION}

# Configuring the container with correct PATH and Go configuration
ENV GOROOT="/usr/local/go" \
    GOPATH="/root/go" \
    PATH="/usr/local/go/bin:/root/go/bin:/root/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

