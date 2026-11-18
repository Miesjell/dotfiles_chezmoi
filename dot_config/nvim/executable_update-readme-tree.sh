#!/usr/bin/env bash
# Script to auto-update the structure tree in README.md

# Generate the tree structure
TREE_OUTPUT=$(cat << 'EOF'
init.lua                 # Entry point - sets leader key and loads modules
lua/
├── settings.lua         # Editor options and preferences
├── keymaps.lua          # Key mappings
├── autocommands.lua     # Autocommands
├── plugins.lua          # lazy.nvim setup and plugin loader
└── plugins/
EOF
)

# Add completion folder
TREE_OUTPUT+=$'\n'"    ├── completion/      # AI and code completion"
for file in lua/plugins/completion/*.lua; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    if [ "$filename" = "init.lua" ]; then continue; fi
    desc=""
    case "$filename" in
        cmp.lua) desc="# nvim-cmp completion engine" ;;
        copilot.lua) desc="# GitHub Copilot integration" ;;
        copilotchat.lua) desc="# Copilot Chat interface" ;;
    esac
    TREE_OUTPUT+=$'\n'"    │   ├── $filename         $desc"
done

# Add core folder
TREE_OUTPUT+=$'\n'"    ├── core/            # Essential development tools"
for file in lua/plugins/core/*.lua; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    if [ "$filename" = "init.lua" ]; then continue; fi
    desc=""
    case "$filename" in
        lspconfig.lua) desc="# LSP configuration" ;;
        treesitter.lua) desc="# Syntax highlighting" ;;
        telescope.lua) desc="# Fuzzy finder" ;;
        debug.lua) desc="# DAP debugger" ;;
        gitsigns.lua) desc="# Git integration" ;;
        neogit.lua) desc="# Git interface" ;;
        toggleterm.lua) desc="# Terminal integration" ;;
        undotree.lua) desc="# Undo history visualizer" ;;
        which_key.lua) desc="# Keybinding helper" ;;
    esac
    TREE_OUTPUT+=$'\n'"    │   ├── $filename   $desc"
done

# Add formatting folder
TREE_OUTPUT+=$'\n'"    ├── formatting/      # Code formatting and linting"
for file in lua/plugins/formatting/*.lua; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    if [ "$filename" = "init.lua" ]; then continue; fi
    desc=""
    case "$filename" in
        conform.lua) desc="# Code formatter" ;;
        lint.lua) desc="# Linter integration" ;;
        autopairs.lua) desc="# Auto-close brackets" ;;
        indent_line.lua) desc="# Indent guides" ;;
    esac
    TREE_OUTPUT+=$'\n'"    │   ├── $filename     $desc"
done

# Add navigation folder
TREE_OUTPUT+=$'\n'"    ├── navigation/      # File and project navigation"
for file in lua/plugins/navigation/*.lua; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    if [ "$filename" = "init.lua" ]; then continue; fi
    desc=""
    case "$filename" in
        harpoon.lua) desc="# Quick file switching" ;;
        yazi.lua) desc="# File manager integration" ;;
    esac
    TREE_OUTPUT+=$'\n'"    │   ├── $filename     $desc"
done

# Add misc folder
TREE_OUTPUT+=$'\n'"    └── misc/            # UI and utilities"
for file in lua/plugins/misc/*.lua; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    if [ "$filename" = "init.lua" ]; then continue; fi
    desc=""
    case "$filename" in
        mini.lua) desc="# Collection of mini plugins" ;;
        noice.lua) desc="# Enhanced UI" ;;
        themery.lua) desc="# Theme switcher" ;;
        todo_comments.lua) desc="# TODO highlighting" ;;
        markdown_preview.lua) desc="# Markdown preview" ;;
    esac
    TREE_OUTPUT+=$'\n'"        ├── $filename            $desc"
done

echo "$TREE_OUTPUT"
echo ""
echo "Copy the output above and paste it into your README.md Structure section"
