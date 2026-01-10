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
| Quick edits | fresh |
| File navigation | yazi + zoxide |
| Shell | zsh + starship |
| File search | fd + fzf |
| Content search | ripgrep |
| File viewing | bat + eza |
| Markdown viewing | glow |

## Directory Structure

```
user-toolkits/alapenna-ghostty/
├── Dockerfile        # Container image definition
├── devbox            # Container lifecycle script for host machine
├── devcontainer.json # Devcontainer configuration (alternative to devbox)
├── scripts/
│   ├── ccm           # Claude commit message generator
│   └── entrypoint.sh # Container startup script (cleanup + idle)
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
#    -> /tmp cleanup runs automatically (files older than 8 hours)
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

### fresh

| Keys | Action |
|------|--------|
| `Ctrl+S` | Save |
| `Ctrl+Q` | Quit |
| `Ctrl+F` | Find |
| `Ctrl+R` | Find and replace |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` | Redo |
| `Ctrl+P` | Command palette |
| `Ctrl+O` | Open file |
| `Ctrl+E` | Toggle file explorer |
| `Ctrl+D` | Select next occurrence |
| `Alt+H/V` | Split horizontal/vertical |
| `Ctrl+Space` | Toggle terminal mode |

## Shell Keybindings

| Keys | Action |
|------|--------|
| `Ctrl+R` | Fuzzy search command history (fzf) |
| `Ctrl+T` | Fuzzy find file, insert path |
| `Alt+C` | Fuzzy find directory and cd |
| `Up/Down` | Search history with current prefix |

## Aliases

| Alias | Command |
|-------|---------|
| `lg` | lazygit |
| `y` | yazi |
| `f` | fresh |
| `e` | fuzzy find + open in fresh |
| `yf` | fuzzy find + open folder in yazi |
| `l` | eza -la --icons |
| `br` | fzf with bat preview |
| `dir` / `dir N` | eza tree (level 1 default, or N) |
| `cat` | bat --paging=never |
| `gp` | git push |
| `ha` | Show all aliases with descriptions |
| `ccm` | Claude commit message generator |
| `todo` | View .todo.md with glow |
| `todo -e` | Edit .todo.md with fresh |

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
y   # yazi file manager
```

### Searching

```bash
# Find files
fd "handler" --type f

# Search content
rg "TODO" --type go

# Fuzzy find and open
fresh $(fd --type f | fzf)
```

### Reading Markdown

```bash
# Render markdown in terminal
glow README.md

# With pager for long files
glow README.md -p

# Browse markdown files in current directory
glow
```

### AI-Assisted Commits

Use `ccm` instead of asking Claude Code to commit. This keeps your conversation context focused on development work rather than polluting it with diffs and commit operations.

```bash
# Generate commit message with Claude (auto-stages all changes)
ccm
# Review the suggested message, then:
#   Y (or Enter) - commit as-is
#   n - abort (changes remain staged)
#   e - edit message before committing
#   u - unstage all changes
```

### Local TODOs

Keep per-project TODOs that won't be committed (globally gitignored):

```bash
# View your todos (rendered markdown)
todo

# Create or edit todos
todo -e
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

### jj (Jujutsu)

Modern VCS that works on top of Git repos. Eliminates the staging area—your working copy is always a commit. Conflicts are stored in commits rather than blocking you. The `jj workspace` feature enables parallel Claude sessions on different features without the complexity of git worktrees.

[jj-vcs.dev](https://jj-vcs.dev)

### gitui

Rust-based Git TUI, noticeably faster than lazygit on large repos. Worth considering if lazygit feels sluggish.

[github.com/extrawurst/gitui](https://github.com/extrawurst/gitui)

### Playwright MCP

MCP server that lets Claude control a browser. Useful for end-to-end testing, scraping documentation, or debugging frontend issues visually. See the alapenna toolkit for a working configuration.

### httpie

CLI HTTP client with human-readable output. Easier than curl for quick API debugging: `http GET api.example.com/users`

`apt install httpie`

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
- [fresh](https://sinelaw.github.io/fresh/) - Modern terminal editor with LSP support
- [starship](https://starship.rs/) - Cross-shell prompt
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like suggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Command highlighting
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) - History search with prefix
- [glow](https://github.com/charmbracelet/glow) - Terminal markdown reader
- [Claude Code](https://docs.anthropic.com/claude-code) - AI coding assistant
- [Ghostty](https://ghostty.org/) - Fast, native terminal emulator
