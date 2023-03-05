function ocrmypdf --wraps=ocrmypdf --description 'run ocrmypdf on host or inside distrobox'
    run_or_fallback ocrmypdf $argv
end
