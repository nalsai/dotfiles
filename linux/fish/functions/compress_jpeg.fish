function compress_jpeg --description 'compress jpeg images using imagemagick'
    if string match --quiet --regex '^[0-9][0-9]?$' "$argv[2]" || test -z "$argv[2]"
        set quality $argv[2]
        test -z "$quality"; and set quality 90

        set filename $argv[1]
        set filename_out (path change-extension '' $filename)-out.jpg

        echo "Compressing $filename to $filename_out with quality $quality"

        distrobox_fallback convert $filename -auto-orient -quality $quality% -interlace Plane -define jpeg:dct-method=float -colorspace sRGB $argv[3..] $filename_out
    else
        echo "Processing multiple files with default settings..."
        for file in $argv[1..]
            compress_jpeg $file
        end
    end
end
