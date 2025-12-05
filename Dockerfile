FROM ubuntu:24.04

ARG TARGETOS
ARG TARGETARCH
ARG GO_VERSION=1.25.1
ARG GOLANGCI_LINT_VERSION=v2.4.0
ARG DOCKER_VERSION=28.4.0
ARG DOCKER_COMPOSE_VERSION=2.39.3
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
    iproute2 \
    nano \
    software-properties-common \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
ARG DOCKER_PACKAGE=5:${DOCKER_VERSION}-1~ubuntu.24.04~noble
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli=${DOCKER_PACKAGE}

# Install Docker Compose plugin
RUN mkdir -p /root/.docker/cli-plugins && \
    if [ "$(uname -m)" = "aarch64" ]; then \
    ARCH=aarch64; \
    elif [ "$(uname -m)" = "x86_64" ]; then \
    ARCH=x86_64; \
    else \
    echo "Unsupported architecture"; exit 1; \
    fi && \
    curl -SL https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH} \
    -o /root/.docker/cli-plugins/docker-compose && \
    chmod +x /root/.docker/cli-plugins/docker-compose

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

# Inject a post-start.sh script that can be used via postStartCommand
COPY post-start.sh /post-start.sh
RUN chmod +x /post-start.sh
