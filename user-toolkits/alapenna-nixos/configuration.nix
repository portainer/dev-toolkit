# NixOS configuration for alapenna dev toolkit
# Equivalent to the alapenna-ghostty Docker container
#
# Usage:
#   1. Create OrbStack NixOS VM: orb create nixos devbox
#   2. Copy this file: orb push devbox configuration.nix /etc/nixos/
#   3. Apply: orb run devbox sudo nixos-rebuild switch
#
# To add X11/Chrome later, uncomment the x11 section at the bottom.

{ config, pkgs, lib, ... }:

let
  # Unstable channel for bleeding-edge packages (claude-code, fresh-editor)
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = config.nixpkgs.config;
  };

in {
  # ============================================
  # System basics
  # ============================================
  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (for some tools)
  nixpkgs.config.allowUnfree = true;

  # Timezone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # ============================================
  # User configuration
  # ============================================
  users.users.dev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    # Password-less sudo for convenience (like running as root in container)
    initialPassword = "dev";
  };

  security.sudo.wheelNeedsPassword = false;

  # ============================================
  # Programs and shells
  # ============================================
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    shellAliases = {
      lg = "lazygit";
      y = "yazi";
      f = "fresh";
      l = "eza -la --icons";
      cat = "bat --paging=never";
      gp = "git push";
    };

    interactiveShellInit = ''
      # History configuration
      HISTSIZE=50000
      SAVEHIST=50000
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt SHARE_HISTORY
      setopt INC_APPEND_HISTORY

      # Shell options
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt CORRECT

      # Key bindings for history substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Tool integrations
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"

      # FZF keybindings
      if [ -n "$(command -v fzf-share)" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      # Environment
      export EDITOR="fresh"
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

      # Plannotator (devcontainer mode on port 8999)
      export PLANNOTATOR_REMOTE=1
      export PLANNOTATOR_PORT=8999

      # Custom functions
      dir() { eza --tree --level="''${1:-1}" --icons; }

      todo() {
        if [[ "$1" == "-e" ]]; then
          fresh .todo.md
        elif [[ -f .todo.md ]]; then
          glow .todo.md
        else
          echo "No .todo.md found. Use 'todo -e' to create one."
        fi
      }

      ha() {
        echo "
  Navigation & Files
    l           List files (eza -la --icons)
    dir [N]     Tree view, depth N (default: 1)
    y           Yazi file manager

  Tools
    lg          Lazygit
    f           Fresh editor
    cat         Bat (syntax highlighting)

  Keybindings
    Ctrl+R      Fuzzy search command history
    Ctrl+T      Fuzzy find file, insert path
    Alt+C       Fuzzy find directory and cd
    Up/Down     Search history with current prefix

  Commands
    todo        View .todo.md
    todo -e     Edit .todo.md
    ccm         Claude commit message
        "
      }
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$line_break$character";

      directory = {
        style = "cyan bold";
        truncation_length = 5;
        truncate_to_repo = false;
      };

      git_branch = {
        style = "purple bold";
        format = "[│ $symbol$branch]($style)";
        symbol = "";
      };

      git_status = {
        style = "red bold";
        format = "[$all_status$ahead_behind]($style)";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕";
        untracked = "?";
        stashed = "";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      character = {
        success_symbol = "[>](green bold)";
        error_symbol = "[>](red bold)";
      };
    };
  };

  programs.git = {
    enable = true;
    config = {
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      push.autoSetupRemote = true;
    };
  };

  # ============================================
  # Docker
  # ============================================
  virtualisation.docker.enable = true;

  # ============================================
  # Development packages
  # ============================================
  environment.systemPackages = with pkgs; [
    # Core development
    go
    nodejs_22
    yarn

    # Go tools
    golangci-lint
    gopls

    # Node tools
    nodePackages.typescript
    nodePackages.typescript-language-server

    # Build essentials
    gcc
    gnumake
    pkg-config

    # Version control
    git
    gh
    lazygit
    delta

    # AI tools (from unstable)
    unstable.claude-code

    # Terminal tools
    zsh
    starship
    fzf
    ripgrep
    fd
    bat
    eza
    jq
    yazi
    zoxide
    glow

    # Editors (from unstable)
    unstable.fresh-editor

    # Utilities
    curl
    wget
    unzip
    file
    lsof
    htop

    # Networking
    iproute2
    iputils
    openssh

    # Custom scripts
    (writeShellScriptBin "ccm" ''
      set -e
      MAX_DIFF_SIZE=''${CCM_MAX_DIFF_SIZE:-300000}

      if [[ -z "$(git status --porcelain)" ]]; then
        echo "No changes to commit."
        exit 1
      fi

      git add -A
      diff=$(git diff --cached)
      diff_size=''${#diff}

      prompt='Write a commit message for this diff following this exact format:

      <subject line: imperative mood, max 72 chars>

      - <bullet point: specific change, starts with verb>
      - <bullet point: specific change, starts with verb>

      Rules:
      - Subject line: imperative mood ("Add X" not "Added X")
      - Body: 3-8 bullet points, each starting with a verb
      - No trailing periods on bullets
      - Output ONLY the message, no markdown fences'

      if [[ $diff_size -gt $MAX_DIFF_SIZE ]]; then
        echo "Diff too large for Claude"
        git diff --cached --stat
        read -p "Enter commit message (or 'q' to abort): " manual_msg
        [[ "$manual_msg" == "q" || -z "$manual_msg" ]] && echo "Aborted." && exit 0
        msg="$manual_msg"
      else
        msg=$(echo "$diff" | claude -p "$prompt")
        echo -e "\nSuggested:\n$msg\n"
      fi

      read -p "Commit? [Y/n/e/u] " choice
      case "''${choice:-y}" in
        n|N) echo "Aborted (changes remain staged)." ;;
        e|E) git commit -e -m "$msg" && read -p "Push? [Y/n] " p && [[ "''${p:-y}" != [nN] ]] && git push ;;
        u|U) git reset HEAD >/dev/null; echo "Unstaged." ;;
        *)   git commit -m "$msg" && read -p "Push? [Y/n] " p && [[ "''${p:-y}" != [nN] ]] && git push ;;
      esac
    '')
  ];

  # ============================================
  # Environment variables
  # ============================================
  environment.variables = {
    TERM = "xterm-256color";
  };

  # ============================================
  # Services
  # ============================================
  services.openssh.enable = true;

  # ============================================
  # Firewall - allow dev ports
  # ============================================
  networking.firewall.allowedTCPPortRanges = [
    { from = 6443; to = 9999; }
  ];

  # ============================================
  # X11 + Chrome (OPTIONAL - uncomment when ready)
  # ============================================
  # To enable, uncomment this section and run: sudo nixos-rebuild switch
  #
  # services.xserver.enable = true;
  #
  # environment.systemPackages = with pkgs; [
  #   google-chrome
  #   xorg.xauth
  # ];
  #
  # # For X11 forwarding via SSH
  # services.openssh.settings.X11Forwarding = true;
}
