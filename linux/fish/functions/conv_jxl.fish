function conv_jxl --description 'Convert and/or compress images to JPEG XL format'
    for file in $argv[1..]
        if test -f $file
            set file_out (path change-extension '' $file).jxl
            echo "Converting $file to $file_out"
            cp $file "$file_out.jpg"
            distrobox_fallback exiftool -all= -tagsfromfile @ -all:all -unsafe -preview_image -thumbnailimage= -overwrite_original "$file_out.jpg"
            distrobox_fallback exiftool -if '$Make =~ /^OLYMPUS /' -Make=OLYMPUS -overwrite_original "$file_out.jpg"
            distrobox_fallback cjxl -e 8 --num_threads=0 --lossless_jpeg=1 -d 0 "$file_out.jpg" "$file_out"
            rm "$file_out.jpg"
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end