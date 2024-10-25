function conv_jxl --description 'Convert and/or compress images to JPEG XL format'
    for file in $argv[1..]
        if test -f $file
            set file_out (path change-extension '' $file).jxl
            echo "Converting $file to $file_out"

            # if the file is a jpeg, run exiftool fix metadata and convert to jxl losslessly
            if string match -q '*.jpg' $file
                cp $file "$file_out.jpg"
                distrobox_fallback exiftool -all= -tagsfromfile @ -all:all -unsafe -preview_image -thumbnailimage= -overwrite_original "$file_out.jpg"
                distrobox_fallback exiftool -if '$Make =~ /^OLYMPUS /' -Make=OLYMPUS -overwrite_original "$file_out.jpg"
                distrobox_fallback cjxl -e 7 --lossless_jpeg=1 -d 0 "$file_out.jpg" "$file_out"
                rm "$file_out.jpg"
            else
                distrobox_fallback cjxl -e 7 -d 1 "$file" "$file_out"
            end
            if test -f $file.out.pp3
                mv $file.out.pp3 $file_out.out.pp3
                gio trash $file
            end
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end