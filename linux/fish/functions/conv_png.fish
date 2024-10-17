function conv_png --description 'Convert and/or compress images to PNG format using imagemagick and oxipng'
    if string match --quiet --regex '^-' "$argv[2]" || test -z "$argv[2]"
        # allow setting custom arguments like --strip safe

        set file $argv[1]
        set file_out $file
        if not string match --quiet --regex '\.png$' $file
            set file_out (path change-extension '' $file).png
            echo "Converting $file to $file_out"
            distrobox_fallback magick $file -auto-orient $file_out
        end

        echo "Compressing $file_out"

        distrobox_fallback oxipng -o 6 $argv[2..] --alpha $file_out
    else
        echo "Processing multiple files..."
        for file in $argv[1..]
            if test -f $file
                conv_png $file
            else
                echo "$file is not an existing file. Skipping..."
            end
        end
    end
end
