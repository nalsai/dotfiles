function conv_jpeg --description 'Convert and/or compress images to JPEG format using imagemagick'
    if string match --quiet --regex '^[0-9][0-9]?$' "$argv[2]" || test -z "$argv[2]"
        # allow setting custom arguments like --strip

        set quality $argv[2]
        test -z "$quality"; and set quality 90

        set file_out (path change-extension '' $file)-out.jpg

        if not string match --quiet --regex '\.jpg$' $file
            set file_out (path change-extension '' $file).jpg
            return
        end

        echo "Compressing $file to $file_out with quality $quality"

        distrobox_fallback magick $file -auto-orient -quality $quality% -interlace Plane -define jpeg:dct-method=float -colorspace sRGB $argv[3..] $file_out
        # -resize 2000x2000\>
    else
        echo "Processing multiple files..."
        for file in $argv[1..]
            if test -f $file
                conv_jpeg $file
            else
                echo "$file is not an existing file. Skipping..."
            end
        end
    end
end
