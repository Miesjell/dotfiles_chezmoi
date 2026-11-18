if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

set -gx PATH /opt/cuda/bin $PATH
set -gx LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
set -gx CUDADIR /opt/cuda

set -x -U GOPATH $HOME/go
set -x -U PATH $PATH $GOPATH/bin

set -U fish_user_paths ~/go/bin $fish_user_paths

set -gx EDITOR nvim

# gaming environment variables
set -gx PROTON_ENABLE_WAYLAND 1
set -gx PROTON_NO_WM_DECORATION 1
set -gx PROTON_DLSS_UPGRADE 1
set -gx PROTON_NVIDIA_LIBS 1

fish_add_path ~/.spicetify
starship init fish | source

function y
    yazi $argv
end


function openpdf
    set file (find . -type f -name '*.pdf' | fzf)
    if test -n "$file"
        librewolf "$file"
    end
end

# create shortcut aliases for command git commands
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gpl='git pull'
alias gcl='git clone'
alias gb='git branch'

alias rcf='ruff check --fix'
alias rf='ruff format'

alias svenv='source .venv/bin/activate.fish'

alias icat='kitten icat'

# uv
fish_add_path "~/.local/share/../bin"
