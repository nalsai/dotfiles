function run_or_fallback
    if command -v $argv[1] >/dev/null
        command $argv[1] $argv[2..-1]
    else
        distrobox enter -e $argv[1] $argv[2..-1]
    end
end
