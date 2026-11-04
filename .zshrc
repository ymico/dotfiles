# ~/.zshrc — настроен 16.10.2026

# сессия GNOME стартовала до chsh и держит SHELL=/bin/bash — поправляем
export SHELL=/bin/zsh

# PATH (как в .bashrc)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# ---------- история ----------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INC_APPEND_HISTORY

# ---------- поведение ----------
setopt AUTO_CD INTERACTIVE_COMMENTS PROMPT_SUBST
unsetopt BEEP

# ---------- автодополнение ----------
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ---------- клавиши как в bash/Windows ----------
bindkey -e
bindkey "^[[H"    beginning-of-line
bindkey "^[[F"    end-of-line
bindkey "^[[3~"   delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
# ↑/↓ ищут по уже набранному началу команды
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# ---------- промпт с веткой git ----------
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{magenta}%b%f'
_vcs_precmd() { vcs_info }
precmd_functions+=(_vcs_precmd)
PROMPT='%F{cyan}%~%f${vcs_info_msg_0_} %(?.%F{green}>%f.%F{red}>%f) '

# ---------- алиасы ----------
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# ---------- плагины (пакеты Fedora) ----------
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# подсветка синтаксиса должна подключаться последней
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---------- приветствие при запуске терминала ----------
# SHLVL<=1 => только самая верхняя оболочка окна; ничего не экспортируем,
# поэтому флаг не может протечь в дочерние процессы.
if [[ -o interactive ]] && (( SHLVL <= 1 )) && (( $+commands[fastfetch] )); then
  fastfetch
fi

# opencode
export PATH=/home/ym1co/.opencode/bin:$PATH
