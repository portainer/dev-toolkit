FROM portainer/dev-toolkit:2024.08

ARG RELEASE_TAG=0.40.3
ARG RELEASE_COMMIT=2804893a83ef162ae6c48e8254717e25c7c7c510
ARG OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"

# Remove the existing openvscode-server directory
RUN rm -rf ${OPENVSCODE_SERVER_ROOT}

# Install Cursor
RUN if [ -z "${RELEASE_TAG}" ] || [ -z "${RELEASE_COMMIT}" ]; then \
        echo "The RELEASE_TAG and RELEASE_COMMIT build args must be set." >&2 && \
        exit 1; \
    fi && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        arch="x64"; \
    elif [ "${arch}" = "aarch64" ]; then \
        arch="arm64"; \
    else \
        echo "Unsupported architecture: ${arch}" >&2 && \
        exit 1; \
    fi && \
    wget https://cursor.blob.core.windows.net/remote-releases/${RELEASE_TAG}-${RELEASE_COMMIT}/vscode-reh-linux-${arch}.tar.gz && \
    tar -xzf vscode-reh-linux-${arch}.tar.gz && \
    mv -f vscode-reh-linux-${arch} ${OPENVSCODE_SERVER_ROOT} && \
    cp ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/cursor ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/code && \
    rm -f vscode-reh-linux-${arch}.tar.gz

# Set the correct permissions for the openvscode-server directory
RUN chown -R openvscode-server:openvscode-server ${OPENVSCODE_SERVER_ROOT}

EXPOSE 3000

ENTRYPOINT [ "/bin/sh", "-c", "exec ${OPENVSCODE_SERVER_ROOT}/bin/cursor-server --host 0.0.0.0 --port 3000 --without-connection-token \"${@}\"", "--" ]