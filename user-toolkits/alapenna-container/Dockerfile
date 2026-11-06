FROM portainer/dev-toolkit:2026.09

ENV HOME=/root
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV EDITOR=fresh
ENV FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# Allows `claude --dangerously-skip-permissions` when running as root inside the container
ENV IS_SANDBOX=1
# Skip AAAA/IPv6 resolution (no IPv6 egress on apple/container) — see README "Networking"
ENV RES_OPTIONS=no-aaaa

# Detect architecture for binary downloads
ARG TARGETARCH

# ============================================
# System packages (combined, with cleanup)
# ============================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    wget \
    curl \
    git \
    file \
    ripgrep \
    fd-find \
    bat \
    jq \
    less \
    lsof \
    unzip \
    gnupg \
    socat \
    binutils \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-13-dev \
    libncurses-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-13-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf $(which fdfind) /usr/local/bin/fd \
    && ln -sf $(which batcat) /usr/local/bin/bat

# fzf: install latest upstream release. Debian's package (0.44.1) is too old
# for the master shell/key-bindings.zsh, which uses flags like --wrap-sign
# added in 0.49.0 — version skew makes Ctrl+R silently bail.
RUN FZF_VERSION=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && curl -Lo fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${ARCH}.tar.gz" \
    && tar xf fzf.tar.gz -C /usr/local/bin/ fzf \
    && rm fzf.tar.gz \
    && mkdir -p /usr/share/fzf \
    && curl -fsSL "https://raw.githubusercontent.com/junegunn/fzf/v${FZF_VERSION}/shell/key-bindings.zsh" -o /usr/share/fzf/key-bindings.zsh

# ============================================
# zsh plugins (no oh-my-zsh) + starship prompt
# ============================================
RUN mkdir -p /root/.zsh \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /root/.zsh/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /root/.zsh/zsh-syntax-highlighting \
    && git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search /root/.zsh/zsh-history-substring-search \
    && rm -rf /root/.zsh/*/.git \
    && curl -sS https://starship.rs/install.sh | sh -s -- -y

# Starship config (two-line minimal)
COPY conf/starship.toml /root/.config/starship.toml

# ============================================
# fresh (terminal editor with LSP)
# ============================================
RUN FRESH_VERSION=$(curl -s "https://api.github.com/repos/sinelaw/fresh/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && curl -Lo fresh.deb "https://github.com/sinelaw/fresh/releases/download/v${FRESH_VERSION}/fresh-editor_${FRESH_VERSION}-1_${ARCH}.deb" \
    && dpkg -i fresh.deb \
    && rm fresh.deb \
    && npm install -g typescript-language-server typescript \
    && npm cache clean --force
COPY conf/fresh.json /root/.config/fresh/config.json

# ============================================
# CLI tools (lazygit, delta, yazi, zoxide, eza)
# ============================================
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x86_64") \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin \
    && rm lazygit.tar.gz lazygit

RUN DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && curl -Lo delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_${ARCH}.deb" \
    && dpkg -i delta.deb \
    && rm delta.deb

RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") \
    && curl -Lo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${ARCH}-unknown-linux-gnu.zip" \
    && unzip yazi.zip \
    && mv yazi-${ARCH}-unknown-linux-gnu/yazi /usr/local/bin/ \
    && mv yazi-${ARCH}-unknown-linux-gnu/ya /usr/local/bin/ \
    && rm -rf yazi.zip yazi-*-unknown-linux-gnu

RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") \
    && curl -Lo eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH}-unknown-linux-gnu.tar.gz" \
    && tar xf eza.tar.gz \
    && mv eza /usr/local/bin/ \
    && rm eza.tar.gz

# ============================================
# GitHub CLI (gh)
# ============================================
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# glow (markdown reader)
# ============================================
RUN GLOW_VERSION=$(curl -s "https://api.github.com/repos/charmbracelet/glow/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && curl -Lo glow.tar.gz "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_${ARCH}.tar.gz" \
    && tar xzf glow.tar.gz \
    && mv glow_*/glow /usr/local/bin/ \
    && rm -rf glow.tar.gz glow_*

# ============================================
# Swift toolchain (via swiftly)
# ============================================
ENV SWIFTLY_HOME_DIR=/root/.local/share/swiftly
ENV SWIFTLY_BIN_DIR=/root/.local/bin
ENV SWIFTLY_TOOLCHAINS_DIR=/root/.local/share/swiftly/toolchains
ENV PATH="${SWIFTLY_BIN_DIR}:${PATH}"

RUN ARCH=$(uname -m) \
    && cd /tmp \
    && curl -fsSLO "https://download.swift.org/swiftly/linux/swiftly-${ARCH}.tar.gz" \
    && tar -xzf "swiftly-${ARCH}.tar.gz" \
    && ./swiftly init --assume-yes --quiet-shell-followup --no-modify-profile \
    && rm -rf "swiftly-${ARCH}.tar.gz" swiftly LICENSE.txt

# ============================================
# Claude Code
# ============================================
RUN curl -fsSL https://claude.ai/install.sh | bash

# uv (Python pkg manager) — installs to /root/.local/bin, already on PATH
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/root/.local/bin sh

# ============================================
# Claude Code plugins (via CLI)
# ============================================
RUN claude plugin marketplace add jarrodwatts/claude-hud \
    && claude plugin marketplace add anthropics/claude-plugins-official \
    && claude plugin marketplace add deviantony/claude-plugins \
    && claude plugin install claude-hud \
    && claude plugin install typescript-lsp@claude-plugins-official \
    && claude plugin install gopls-lsp@claude-plugins-official \
    && claude plugin install swift-lsp@claude-plugins-official \
    && claude plugin install skill-creator@claude-plugins-official \
    && claude plugin install cdx@deviantony-plugins

# Claude Code config files
COPY conf/claude-hud.json /root/.claude/plugins/claude-hud/config.json
COPY conf/claude-settings.json /root/.claude/settings.json

# User-level CLAUDE.md (global instructions)
COPY conf/CLAUDE.md /root/.claude/CLAUDE.md

# ============================================
# Git config
# ============================================
RUN git config --global core.pager delta \
    && git config --global interactive.diffFilter "delta --color-only" \
    && git config --global delta.navigate true \
    && git config --global delta.side-by-side true \
    && git config --global delta.line-numbers true \
    && git config --global merge.conflictstyle diff3 \
    && git config --global diff.colorMoved default \
    && git config --global push.autoSetupRemote true

# ============================================
# Shell configuration (.zshrc)
# ============================================
COPY conf/zshrc /root/.zshrc

# ============================================
# Custom scripts
# ============================================
COPY scripts/ccm /usr/local/bin/ccm
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/ccm /entrypoint.sh

# ============================================
# Set zsh as default shell
# ============================================
RUN chsh -s $(which zsh)

# ============================================
# Build provenance
# Placed last so changing the commit doesn't bust earlier layer cache.
# Inspect inside the container with: echo $DEVBOX_GIT_COMMIT
# ============================================
ARG GIT_COMMIT=unknown
ENV DEVBOX_GIT_COMMIT=${GIT_COMMIT}

WORKDIR /workspace
SHELL ["/bin/zsh", "-c"]

ENTRYPOINT ["/entrypoint.sh"]
