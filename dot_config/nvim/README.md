# Neovim Configuration

A modular Neovim configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), featuring modern development tools, AI-powered completion, and an organized plugin structure.

## Structure

```
init.lua                 # Entry point - sets leader key and loads modules
lua/
├── settings.lua         # Editor options and preferences
├── keymaps.lua          # Key mappings
├── autocommands.lua     # Autocommands
├── plugins.lua          # lazy.nvim setup and plugin loader
└── plugins/
    ├── completion/      # AI and code completion
    │   ├── cmp.lua         # nvim-cmp completion engine
    │   ├── copilotchat.lua         # Copilot Chat interface
    │   ├── copilot.lua         # GitHub Copilot integration
    ├── core/            # Essential development tools
    │   ├── debug.lua   # DAP debugger
    │   ├── gitsigns.lua   # Git integration
    │   ├── lspconfig.lua   # LSP configuration
    │   ├── neogit.lua   # Git interface
    │   ├── telescope.lua   # Fuzzy finder
    │   ├── toggleterm.lua   # Terminal integration
    │   ├── treesitter.lua   # Syntax highlighting
    │   ├── undotree.lua   # Undo history visualizer
    │   ├── which_key.lua   # Keybinding helper
    ├── formatting/      # Code formatting and linting
    │   ├── autopairs.lua     # Auto-close brackets
    │   ├── conform.lua     # Code formatter
    │   ├── indent_line.lua     # Indent guides
    │   ├── lint.lua     # Linter integration
    ├── navigation/      # File and project navigation
    │   ├── harpoon.lua     # Quick file switching
    │   ├── yazi.lua     # File manager integration
    └── misc/            # UI and utilities
        ├── focus.lua            
        ├── markdown_preview.lua            # Markdown preview
        ├── mini.lua            # Collection of mini plugins
        ├── noice.lua            # Enhanced UI
        ├── pdf_viewer.lua            
        ├── themery.lua            # Theme switcher
        ├── todo_comments.lua            # TODO highlighting
        ├── vimtex.lua            
        ├── zen.lua      
```


## Dependencies

### Required
- **Neovim** >= 0.9.0
- **git** - Version control
- **ripgrep** - Fast file searching (for Telescope)
- **gcc/make** - Compiling native extensions
- **Nerd Font** - For icons (set `vim.g.have_nerd_font = true` in settings)

### Optional
- **npm** - For LSP servers and TypeScript support
- **zoxide** - Enhanced directory navigation
- **xclip/xsel** (Linux) or **pbcopy** (macOS) - Clipboard support
- Language-specific tools (go, rust, python, etc.) for their respective LSP servers

## Installation

1. **Backup existing config** (if any):
   \`\`\`bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   \`\`\`

2. **Clone this repository**:
   \`\`\`bash
   git clone <your-repo-url> ~/.config/nvim
   \`\`\`

3. **Launch Neovim**:
   \`\`\`bash
   nvim
   \`\`\`
   
   Lazy.nvim will automatically install all plugins on first launch.

## Getting Started

- Press `<space>sh` to search help documentation
- Press `<space>sk` to search keymaps
- Run `:Lazy` to manage plugins
- Run `:Mason` to manage LSP servers, formatters, and linters
- Run `:checkhealth` to diagnose issues

## Acknowledgments

Built on top of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) by [TJ DeVries](https://github.com/tjdevries). Huge thanks to TJ and the Neovim community for creating such an excellent starting point and educational resource!
