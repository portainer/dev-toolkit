FROM portainer/dev-toolkit:2024.10

# This image uses /root as the home instead of /home/workspace
ENV HOME=/root
# Create a workspace folder
RUN mkdir -pv /workspace && ln -s /workspace /root/workspace

# Prepare a ssh folder placeholder to transfer keys
RUN mkdir -p /root/.ssh

# Prepare a git folder for storing git configuration
RUN mkdir -p /root/.config/git

# Install httpie: http://httpie.io/
RUN curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add - \
    && curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list \
    && apt-get update && apt-get install httpie -y

# Install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)"

ENV SHELL=/bin/zsh

# Install docker compose plugin
RUN mkdir -p /root/.docker/cli-plugins/ \
    && curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /root/.docker/cli-plugins/docker-compose \
    && chmod +x /root/.docker/cli-plugins/docker-compose

# Install air
RUN go install github.com/air-verse/air@latest

# Configure git to use SSH
# This is useful to retrieve private Go packages
# Note: this has to be done as one of the last steps in the image build process as it can
# mess up with previous steps using Git (oh-my-zsh installation for example)
RUN printf '[url "ssh://git@github.com/"]\n\tinsteadOf = https://github.com/\n' > /root/.gitconfig

# Update .zshrc
RUN echo 'export PATH="$PATH:/root/.local/bin"' >> /root/.zshrc