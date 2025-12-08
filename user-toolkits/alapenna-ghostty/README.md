# alapenna-ghostty toolkit

A terminal-native development environment optimized for use with Ghostty (or any modern terminal emulator). This toolkit eliminates the need for a traditional IDE by combining Claude Code for AI-assisted development with lightweight terminal tools for viewing, navigation, and git operations.

## Philosophy

Let Claude Code handle the cognitive heavy lifting while lightweight terminal tools handle viewing, navigation, and git operations. No more context switching between terminal and IDE.

Use your terminal emulator's native tabs and splits for window management - no need for tmux.

## Tool Stack

| Need | Tool |
|------|------|
| AI-assisted development | Claude Code |
| Git operations | lazygit + delta |
| Quick edits | micro |
| File navigation | yazi + zoxide |
| Shell | zsh + oh-my-zsh + spaceship |
| File search | fd + fzf |
| Content search | ripgrep |
| File viewing | bat + eza |

## Directory Structure

```
user-toolkits/alapenna-ghostty/
├── Dockerfile        # Container image definition
├── devbox            # Container lifecycle script for host machine
├── devcontainer.json # Devcontainer configuration (alternative to devbox)
└── README.md         # This file
```

## Build

```bash
# From the dev-toolkit root directory
make alapenna-ghostty
```

This builds an ARM64 image tagged as `portainer-dev-toolkit:alapenna-ghostty`.

## Usage with Ghostty (Recommended)

The `devbox` script manages the container lifecycle. One command handles everything: creating, starting, and attaching.

### Installation (macOS)

```bash
# Install the devbox script
# From the user-toolkits/alapenna-ghostty directory
cp devbox ~/.local/bin/
chmod +x ~/.local/bin/devbox

# Ensure ~/.local/bin is in your PATH (add to ~/.zshrc if needed)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Add a short alias
echo 'alias db="devbox"' >> ~/.zshrc

source ~/.zshrc
```

### Daily Workflow

```bash
# 1. Start OrbStack (or Docker)

# 2. Enter the dev container:
db                        # Or: devbox

# 3. You're now in the container. Start working!

# 4. Open more terminals as needed:
#    - Use Ghostty's Cmd+T for new tabs
#    - Use Ghostty's Cmd+D for horizontal split
#    - Run 'db' in each new terminal to connect

# 5. Exit with Ctrl+D or 'exit'
#    Container keeps running in the background
```

### After Reboot

```bash
# 1. Start OrbStack
# 2. Run db (or devbox)
#    -> Container restarts automatically
#    -> /workspace volume persists all your code
```

### devbox Commands

```bash
devbox              # Enter container (creates/starts if needed)
devbox stop         # Stop the container
devbox destroy      # Remove container (volume persists)
devbox status       # Show container and volume status
```

## Alternative: Devcontainer

If you prefer using an IDE with devcontainer support:

1. Configure your project to use the `devcontainer.json` file in this directory
2. Open in VS Code or any devcontainer-compatible tool

## First Time Setup

After starting the container for the first time:

```bash
# Configure git
git config --global user.email <email>
git config --global user.name <name>
git config --global commit.gpgsign true
git config --global user.signingkey <key_id>
git config --global url.ssh://git@github.com/.insteadOf https://github.com/

# Login to GitHub CLI
gh auth login
# Follow the prompts to authenticate

# Login to Claude Code
claude
# Follow the authentication prompts
```

## Keyboard Shortcuts

### Ghostty

| Keys | Action |
|------|--------|
| `Cmd+T` | New tab |
| `Cmd+D` | Split horizontally |
| `Cmd+Shift+D` | Split vertically |
| `Cmd+[/]` | Navigate splits |
| `Cmd+1-9` | Switch to tab |
| `Cmd+W` | Close tab/split |

### lazygit

| Keys | Action |
|------|--------|
| `space` | Stage/unstage file |
| `c` | Commit |
| `P` | Push |
| `p` | Pull |
| `b` | Branches |
| `?` | Help |

### yazi

| Keys | Action |
|------|--------|
| `h/l` | Navigate up/into directory |
| `j/k` | Move selection |
| `Enter` | Open file |
| `q` | Quit |
| `space` | Select file |
| `d` | Delete |
| `r` | Rename |

### micro

| Keys | Action |
|------|--------|
| `Ctrl-s` | Save |
| `Ctrl-q` | Quit |
| `Ctrl-f` | Find |
| `Ctrl-z` | Undo |

## Aliases

| Alias | Command |
|-------|---------|
| `lg` | lazygit |
| `y` | yazi |
| `yy` | yazi with cd-on-exit |
| `m` | micro |
| `l` | eza -la --icons |
| `cat` | bat --paging=never |

## Tips

### Reviewing Code Without an IDE

```bash
# Full file with syntax highlighting
bat src/api/handler.go

# Git diff with delta (automatic via git config)
git diff

# Interactive staging with lazygit
lg
# Press 'space' on individual hunks to stage them

# File tree navigation
yy  # yazi with cd-on-exit
```

### Searching

```bash
# Find files
fd "handler" --type f

# Search content
rg "TODO" --type go

# Fuzzy find and open
micro $(fd --type f | fzf)
```

## Mounts

This devcontainer uses a Docker volume for `/workspace` for better performance (see [VS Code docs](https://code.visualstudio.com/remote/advancedcontainers/improve-performance#_use-a-named-volume-for-your-entire-source-tree)).

Shared folders with the host:
- `/root/.ssh`: SSH keys
- `/root/.gnupg`: GPG keys
- `/src`: Host repositories (from `~/workspaces/toolkit-workspace`)
- `/share-tmp`: Temporary file sharing (from `~/tmp/dev-toolkit`)

## Port Forwarding

Forwarded ports (localhost only): 6443, 8999, 9000

Published ports (accessible over host IP): 8000, 9443

## Potential Enhancements

The following tools could be added to enhance this toolkit:

| Tool | Description | Notes |
|------|-------------|-------|
| **lazydocker** | Terminal UI for Docker management | `curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \| bash` |
| **neovim** | Advanced terminal editor (for vim users) | `apt-get install neovim` |
| **gitui** | Fast Git TUI written in Rust (alternative to lazygit) | Download from [gitui releases](https://github.com/extrawurst/gitui/releases) |
| **Playwright MCP** | Browser automation for Claude Code | See alapenna toolkit for reference |
| **httpie** | User-friendly HTTP client | `apt-get install httpie` |
| **kubectl + helm** | Kubernetes tooling | See alapenna toolkit for reference |

To add any of these, modify the Dockerfile or install them manually inside the container.

## Troubleshooting

### Claude Code authentication

Login manually after starting the container:
```bash
claude
# Follow the prompts to authenticate
```

### zoxide not tracking directories

zoxide learns over time. Use `cd` normally and it will start suggesting paths:
```bash
z <partial-path>  # Jump to a learned directory
```

## References

- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git
- [delta](https://github.com/dandavison/delta) - Better git diffs
- [yazi](https://github.com/sxyazi/yazi) - Terminal file manager
- [micro](https://micro-editor.github.io/) - Modern terminal editor
- [spaceship-prompt](https://spaceship-prompt.sh/) - Zsh prompt
- [Claude Code](https://docs.anthropic.com/claude-code) - AI coding assistant
- [Ghostty](https://ghostty.org/) - Fast, native terminal emulator
