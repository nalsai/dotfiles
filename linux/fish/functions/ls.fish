function ls --wraps=exa --description 'alias ls exa'
    if command -v exa >/dev/null
        exa $argv
    else
      command ls $argv --color=auto
    end
end
