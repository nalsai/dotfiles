function conv_flac --description 'Convert audio files to FLAC format using ffmpeg'
    for file in $argv[1..]
        if test -f $file

            set file_out (path change-extension '' $file)-out.flac
            if not string match --quiet --regex '\.flac$' $file
                set file_out (path change-extension '' $file).flac
            end

            echo "Converting $file to $file_out"
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $file -c:a flac -compression_level 8 $file_out
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end
