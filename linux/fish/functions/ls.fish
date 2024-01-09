function ls --wraps=eza --description 'alias ls eza'
    if command -v eza >/dev/null
        eza $argv
    else
      command ls $argv --color=auto
    end
end
