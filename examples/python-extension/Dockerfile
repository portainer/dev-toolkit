FROM portainer/dev-toolkit:2024.08

# First, you'll need to retrieve the unique identifier associated to the extension
# It can be found on VSCode extension marketplace: https://marketplace.visualstudio.com/items?itemName=ms-python.python
# The unique identifier for this extension is: ms-python.python

# A unique identifier is usually defined using the following format PUBLISHER.PACKAGE

# Just update the EXT_PUBLISHER and EXT_PACKAGE environment variables appropriately.

## Python extension ID: ms-python.python
RUN EXT_PUBLISHER=ms-python EXT_PACKAGE=python && \
    mkdir -pv "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}" && \
    curl -sSL "https://${EXT_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXT_PUBLISHER}/extension/${EXT_PACKAGE}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" | bsdtar xvf - --strip-components=1 -C "/home/workspace/.openvscode-server/extensions/${EXT_PUBLISHER}.${EXT_PACKAGE}"

