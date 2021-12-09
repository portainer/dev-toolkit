FROM cr.portainer.io/portainer/dev-toolkit:2021.11

# This image uses /root as the home instead of /home/workspace
ENV HOME /root

# Copy the settings/extensions from the base image
RUN mv /home/workspace/.openvscode-server /root/.openvscode-server

# Create a workspace folder
RUN mkdir -pv /workspace && ln -s /workspace /root/workspace

# Prepare a ssh folder placeholder to transfer keys
RUN mkdir /root/.ssh

# Install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)"

ENV SHELL /bin/zsh

## Night owl theme extension ID: sdras.night-owl
RUN EXT_PUBLISHER=sdras EXT_PACKAGE=night-owl && \
    mkdir -pv "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Material icon theme extension ID: PKief.material-icon-theme	
RUN EXT_PUBLISHER=PKief EXT_PACKAGE=material-icon-theme && \
    mkdir -pv "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "${HOME}/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

## Install docker compose plugin
RUN mkdir -p /root/.docker/cli-plugins/ && \
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && \
    chmod +x ~/.docker/cli-plugins/docker-compose