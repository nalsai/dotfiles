function conv_flac --description 'Convert audio files to FLAC format using ffmpeg'
    for file in $argv[1..]
        if test -f $file
            set filename "$file"
            set filename_out (path change-extension '' $filename)-out.flac

            if not string match --quiet --regex '\.flac$' $filename
                set filename_out (path change-extension '' $filename).flac
            end

            echo "Converting $filename to $filename_out"
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $filename -c:a flac -compression_level 8 $filename_out
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end
