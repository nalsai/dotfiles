function conv_jpeg --description 'Convert and/or compress images to JPEG format using imagemagick'
    if string match --quiet --regex '^[0-9][0-9]?$' "$argv[2]" || test -z "$argv[2]"
        # allow setting custom arguments like --strip

        set quality $argv[2]
        test -z "$quality"; and set quality 90

        set filename $argv[1]
        set filename_out (path change-extension '' $filename)-out.jpg

        if not string match --quiet --regex '\.jpg$' $filename
            set filename_out (path change-extension '' $filename).jpg
            return
        end

        echo "Compressing $filename to $filename_out with quality $quality"

        distrobox_fallback convert $filename -auto-orient -quality $quality% -interlace Plane -define jpeg:dct-method=float -colorspace sRGB $argv[3..] $filename_out
    else
        echo "Processing multiple files..."
        for file in $argv[1..]
            if test -f $file
                compress_jpeg $file
            else
                echo "$file is not an existing file. Skipping..."
            end
        end
    end
end
