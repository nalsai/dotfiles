function conv_webm --description 'Convert mkv to webm'
    for file in $argv[1..]
        if test -f $file
            set filename "$file"
            set filename_out (path change-extension '' $filename)-out.webm

            echo "Converting $filename to $filename_out"
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $filename -c copy -map_metadata 0 $filename_out
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end
