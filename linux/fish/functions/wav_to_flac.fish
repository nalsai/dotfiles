function wav_to_flac --description 'Convert all WAV files in the current directory and any subdirectories to FLAC format'
    for file in **.wav
        if test -f $file
            set filename_flac (basename $file .wav).flac
            set output_dir (dirname $file)
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $file -c:a flac $output_dir/$filename_flac
            echo "Converted $file to $filename_flac"
        end
    end
end
