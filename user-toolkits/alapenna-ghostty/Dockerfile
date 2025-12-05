FROM portainer/dev-toolkit:2025.12

ENV HOME=/root
ENV TERM=xterm-256color

# Detect architecture for binary downloads
ARG TARGETARCH

# ============================================
# zsh + oh-my-zsh + spaceship prompt
# ============================================
RUN apt-get update && apt-get install -y zsh wget curl git \
    && rm -rf /var/lib/apt/lists/*

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install spaceship prompt
RUN git clone https://github.com/spaceship-prompt/spaceship-prompt.git "/root/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1 \
    && ln -s "/root/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "/root/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

# Install zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Configure zsh
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/' /root/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc

# ============================================
# Core CLI tools
# ============================================
RUN apt-get update && apt-get install -y \
    file \
    fzf \
    ripgrep \
    fd-find \
    bat \
    jq \
    lsof \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Symlinks for Ubuntu naming quirks
RUN ln -sf $(which fdfind) /usr/local/bin/fd \
    && ln -sf $(which batcat) /usr/local/bin/bat

# ============================================
# micro (nano replacement)
# ============================================
RUN curl https://getmic.ro | bash && mv micro /usr/local/bin/

# ============================================
# lazygit
# ============================================
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x86_64") \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin \
    && rm lazygit.tar.gz lazygit

# ============================================
# delta (better git diffs)
# ============================================
RUN DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && curl -Lo delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_${ARCH}.deb" \
    && dpkg -i delta.deb \
    && rm delta.deb

# ============================================
# yazi (file manager)
# ============================================
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") \
    && curl -Lo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${ARCH}-unknown-linux-gnu.zip" \
    && unzip yazi.zip \
    && mv yazi-${ARCH}-unknown-linux-gnu/yazi /usr/local/bin/ \
    && mv yazi-${ARCH}-unknown-linux-gnu/ya /usr/local/bin/ \
    && rm -rf yazi.zip yazi-*-unknown-linux-gnu

# ============================================
# zoxide (smart cd)
# ============================================
RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# ============================================
# eza (modern ls)
# ============================================
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") \
    && curl -Lo eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH}-unknown-linux-gnu.tar.gz" \
    && tar xf eza.tar.gz \
    && mv eza /usr/local/bin/ \
    && rm eza.tar.gz

# ============================================
# Claude Code (official installer)
# ============================================
RUN curl -fsSL https://claude.ai/install.sh | bash

# ============================================
# Git config for delta
# ============================================
RUN git config --global core.pager delta \
    && git config --global interactive.diffFilter "delta --color-only" \
    && git config --global delta.navigate true \
    && git config --global delta.side-by-side true \
    && git config --global delta.line-numbers true \
    && git config --global merge.conflictstyle diff3 \
    && git config --global diff.colorMoved default

# ============================================
# Shell integration (append to .zshrc)
# ============================================
RUN cat >> /root/.zshrc <<'EOF'

# Add Claude Code to PATH
export PATH="$HOME/.local/bin:$PATH"

# Set micro as default editor (used by yazi, git, etc.)
export EDITOR="micro"

# Zoxide
eval "$(zoxide init zsh)"

# Aliases
alias lg="lazygit"
alias y="yazi"
alias m="micro"
alias cat="bat --paging=never"
alias l="eza -la --icons"

# Yazi: cd to directory on exit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# FZF defaults
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Spaceship config
export SPACESHIP_PROMPT_ADD_NEWLINE=false
export SPACESHIP_CHAR_SYMBOL="❯ "
export SPACESHIP_GIT_STATUS_STASHED=""
EOF

# ============================================
# Set zsh as default shell
# ============================================
RUN chsh -s $(which zsh)

WORKDIR /workspace
SHELL ["/bin/zsh", "-c"]
