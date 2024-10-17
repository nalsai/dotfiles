function conv_webm --description 'Convert mkv to webm'
    for file in $argv[1..]
        if test -f $file
            set file_out (path change-extension '' $file).webm
            echo "Converting $file to $file_out"
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $file -c copy -map_metadata 0 $file_out
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end
