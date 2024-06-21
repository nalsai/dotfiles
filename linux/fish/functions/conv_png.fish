function conv_png --description 'Convert and/or compress images to PNG format using imagemagick and oxipng'
    if string match --quiet --regex '^-' "$argv[2]" || test -z "$argv[2]"
        # allow setting custom arguments like --strip safe

        set filename $argv[1]
        set filename_out $filename

        if not string match --quiet --regex '\.png$' $filename
            set filename_out (path change-extension '' $filename).png
            echo "Converting $filename to $filename_out"
            distrobox_fallback convert $filename -auto-orient $filename_out
        end

        echo "Compressing $filename_out"

        distrobox_fallback oxipng -o 6 $argv[2..] --alpha $filename_out
    else
        echo "Processing multiple files..."
        for file in $argv[1..]
            if test -f $file
                compress_png $filele
            else
                echo "$file is not an existing file. Skipping..."
            end
        end
    end
end
