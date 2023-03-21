function cat --wraps=bat --description 'alias cat bat'
    if command -v bat >/dev/null
        bat $argv
    else if command -v batcat >/dev/null
        batcat $argv
    else
        command cat $argv
    end
end
