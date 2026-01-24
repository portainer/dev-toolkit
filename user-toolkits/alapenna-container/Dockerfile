FROM portainer/dev-toolkit:2025.12

ENV HOME=/root
ENV TERM=xterm-256color

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
    fzf \
    ripgrep \
    fd-find \
    bat \
    jq \
    lsof \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf $(which fdfind) /usr/local/bin/fd \
    && ln -sf $(which batcat) /usr/local/bin/bat

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
RUN mkdir -p /root/.config && cat > /root/.config/starship.toml <<'EOF'
format = """
$directory\
$git_branch\
$git_status\
$line_break\
$character"""

[directory]
style = "cyan bold"
truncation_length = 5
truncate_to_repo = false

[git_branch]
style = "purple bold"
format = "[│ $symbol$branch]($style)"
symbol = ""

[git_status]
style = "red bold"
format = "[$all_status$ahead_behind]($style)"
conflicted = "="
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕"
untracked = "?"
stashed = ""
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"

[character]
success_symbol = "[>](green bold)"
error_symbol = "[>](red bold)"
EOF

# ============================================
# fresh (terminal editor with LSP)
# ============================================
RUN FRESH_VERSION=$(curl -s "https://api.github.com/repos/sinelaw/fresh/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && curl -Lo fresh.deb "https://github.com/sinelaw/fresh/releases/download/v${FRESH_VERSION}/fresh-editor_${FRESH_VERSION}-1_${ARCH}.deb" \
    && dpkg -i fresh.deb \
    && rm fresh.deb \
    && npm install -g typescript-language-server typescript \
    && npm cache clean --force \
    && mkdir -p /root/.config/fresh && cat > /root/.config/fresh/config.json <<'EOF'
{
  "editor": {
    "tab_size": 2
  }
}
EOF

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
RUN go install github.com/charmbracelet/glow@latest \
    && go clean -cache -modcache

# ============================================
# Claude Code + Plannotator CLI
# ============================================
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && curl -fsSL https://plannotator.ai/install.sh | bash

# ============================================
# Claude Code plugins (via CLI)
# ============================================
ENV PATH="/root/.local/bin:${PATH}"
RUN claude plugin marketplace add jarrodwatts/claude-hud \
    && claude plugin marketplace add backnotprop/plannotator \
    && claude plugin marketplace add anthropics/claude-plugins-official \
    && claude plugin install claude-hud \
    && claude plugin install plannotator@plannotator \
    && claude plugin install typescript-lsp@claude-plugins-official \
    && claude plugin install gopls-lsp@claude-plugins-official

# Claude Code config files
RUN mkdir -p $HOME/.claude/plugins/claude-hud \
    && cat > $HOME/.claude/plugins/claude-hud/config.json <<'EOF'
{
  "layout": "default",
  "display": {
    "showModel": true,
    "showContextBar": true,
    "showTools": false,
    "showAgents": true,
    "showTodos": true,
    "showConfigCounts": false,
    "showTokenBreakdown": true,
    "showUsage": true,
    "showDuration": false
  },
  "gitStatus": {
    "enabled": true,
    "showDirty": true,
    "showAheadBehind": true
  }
}
EOF

RUN cat > $HOME/.claude/settings.json <<'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "node \"$(ls -td ~/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | head -1)dist/index.js\""
  },
  "enabledPlugins": {
    "claude-hud@claude-hud": true,
    "plannotator@plannotator": true
  },
  "alwaysThinkingEnabled": true,
  "permissions": {
    "deny": [
      "Read(**/.env*)",
      "Read(~/.ssh/**)",
      "Read(~/.docker/**)"
    ]
  }
}
EOF

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
RUN cat > /root/.zshrc <<'EOF'
# ----------------------------------------
# Zsh plugins (no oh-my-zsh framework)
# ----------------------------------------
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# ----------------------------------------
# History configuration
# ----------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS  # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS     # Don't show duplicates when searching
setopt SHARE_HISTORY         # Share history across terminals
setopt INC_APPEND_HISTORY    # Add commands immediately

# ----------------------------------------
# Shell options
# ----------------------------------------
setopt AUTO_CD               # Type directory name to cd into it
setopt AUTO_PUSHD            # cd pushes to directory stack
setopt PUSHD_IGNORE_DUPS     # Don't push duplicates
setopt CORRECT               # Spelling correction for commands

# ----------------------------------------
# Key bindings
# ----------------------------------------
# Up/down arrow searches history with current prefix
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# fzf keybindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
source /usr/share/doc/fzf/examples/key-bindings.zsh

# ----------------------------------------
# Environment
# ----------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="fresh"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Plannotator (devcontainer mode on port 8999)
export PLANNOTATOR_REMOTE=1
export PLANNOTATOR_PORT=8999

# ----------------------------------------
# Tool integrations
# ----------------------------------------
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# ----------------------------------------
# Aliases
# ----------------------------------------
alias lg="lazygit"
alias y="yazi"
alias f="fresh"
alias e='file=$(fd --type f --hidden --no-ignore --follow --exclude .git | fzf) && [ -n "$file" ] && fresh "$file"'
alias yf='d=$(fd --type d --hidden --no-ignore --follow --exclude .git | fzf) && [ -n "$d" ] && yazi "$d"'
alias cat="bat --paging=never"
alias l="eza -la --icons"
alias br='fzf --preview "bat --color=always {}"'
alias gp="git push"

dir() { eza --tree --level="${1:-1}" --icons; }

# ----------------------------------------
# Help command for aliases
# ----------------------------------------
ha() {
  echo "
  Navigation & Files
    l           List files (eza -la --icons)
    dir [N]     Tree view, depth N (default: 1)
    br          Browse files with preview (fzf + bat)
    e           Fuzzy find + open in editor
    y           Yazi file manager
    yf          Fuzzy find folder + open in yazi

  Tools
    lg          Lazygit
    f           Fresh editor
    cat         Bat (syntax highlighting)

  Keybindings
    Ctrl+R      Fuzzy search command history
    Ctrl+T      Fuzzy find file, insert path
    Alt+C       Fuzzy find directory and cd
    Up/Down     Search history with current prefix

  Productivity
    ccm         Claude commit message
"
}

EOF

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

WORKDIR /workspace
SHELL ["/bin/zsh", "-c"]

ENTRYPOINT ["/entrypoint.sh"]
