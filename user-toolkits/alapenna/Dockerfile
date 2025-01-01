FROM portainer/dev-toolkit:2024.12

# Create a specific folder for Git configurations
RUN mkdir -p /root/.config/git

# Install httpie: http://httpie.io/
RUN curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add - \
    && curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list \
    && apt-get update && apt-get install httpie -y

# Install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)"
ENV SHELL=/bin/zsh

# Install kubectl
RUN cd /tmp && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm /tmp/kubectl

# Install helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Golang tools: air, gonb, protoc go plugins and dependencies
# https://github.com/janpfeifer/gonb?tab=readme-ov-file#linux-and-macos-installation-using-standard-go-tools
# https://grpc.io/docs/languages/go/quickstart/#prerequisites
RUN go install github.com/air-verse/air@latest && \
    go install github.com/janpfeifer/gonb@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install golang.org/x/tools/gopls@latest && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Install gonb kernel
RUN gonb --install

# Install protocol buffer compiler
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v29.2/protoc-29.2-linux-aarch_64.zip -o /tmp/protoc.zip && \
    unzip /tmp/protoc.zip -d /root/.local

# Update .zshrc
RUN echo 'export PATH="$PATH:/root/.local/bin"' >> /root/.zshrc