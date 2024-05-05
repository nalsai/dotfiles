function flacseektabler --description 'Remove seektable and compute new seekpoints for all FLAC files'
    distrobox_fallback metaflac --remove --block-type=SEEKTABLE **.flac
    echo "Creating seekpoints..."
    distrobox_fallback metaflac --add-seekpoint=1s **.flac
end
