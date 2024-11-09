FROM portainer/dev-toolkit:2024.11

# Create a workspace folder and link it to /root/workspace
# I also create specific folders for SSH keys and Git configuration
RUN mkdir -p /workspace /root/.ssh /root/.config/git && \
    ln -s /workspace /root/workspace

# Install httpie: http://httpie.io/
RUN curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add - \
    && curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list \
    && apt-get update && apt-get install httpie -y

# Install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)"
ENV SHELL=/bin/zsh

# Install air
RUN go install github.com/air-verse/air@latest

# Configure git to use SSH
# This is useful to retrieve private Go packages
# Note: this has to be done as one of the last steps in the image build process as it can
# mess up with previous steps using Git (oh-my-zsh installation for example)
RUN printf '[url "ssh://git@github.com/"]\n\tinsteadOf = https://github.com/\n' > /root/.gitconfig

# Update .zshrc
RUN echo 'export PATH="$PATH:/root/.local/bin"' >> /root/.zshrc
