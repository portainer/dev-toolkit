FROM portainer/dev-toolkit:2024.08

# This image uses /root as the home instead of /home/workspace
ENV HOME=/root

# Copy the settings/extensions from the base image
RUN mv /home/workspace/.openvscode-server /root/.openvscode-server

# Create a workspace folder
RUN mkdir -pv /workspace && ln -s /workspace /root/workspace

# Prepare a ssh folder placeholder to transfer keys
RUN mkdir /root/.ssh

# Prepare a git folder for storing git configuration
RUN mkdir /root/.config/git

# Install httpie: http://httpie.io/
RUN curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add - \
    && curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list \
    && apt-get update && apt-get install httpie -y

# Install pip
RUN apt-get install python3-pip -y

# Install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"

ENV SHELL /bin/zsh

## Night owl theme extension ID: sdras.night-owl
RUN EXT_PUBLISHER=sdras EXT_PACKAGE=night-owl && \
    mkdir -pv "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Material icon theme extension ID: PKief.material-icon-theme	
RUN EXT_PUBLISHER=PKief EXT_PACKAGE=material-icon-theme && \
    mkdir -pv "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Github copilot extension ID: GitHub.copilot
RUN EXT_PUBLISHER=GitHub EXT_PACKAGE=copilot && \
    mkdir -pv "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Python extension: ms-python.python
RUN EXT_PUBLISHER=ms-python EXT_PACKAGE=python && \
    mkdir -pv "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Install docker compose plugin
RUN mkdir -p /root/.docker/cli-plugins/ && \
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && \
    chmod +x ~/.docker/cli-plugins/docker-compose

## Install air
RUN go install github.com/air-verse/air@latest

## Install python tools
RUN pip install --user --upgrade pipenv twine requests-toolbelt

# Configure git to use SSH
# This is useful to retrieve private Go packages
# Note: this has to be done as one of the last steps in the image build process as it can
# mess up with previous steps using Git (oh-my-zsh installation for example)
RUN printf '\
[url "ssh://git@github.com/"] \n\
	insteadOf = https://github.com/ \n\
' > /root/.gitconfig

# Update .zshrc
RUN echo 'export PATH="$PATH:/root/.local/bin"' >> /root/.zshrc