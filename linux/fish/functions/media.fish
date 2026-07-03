function media --description 'Optimize, check, fix, or convert TIFF/PNG/JPG/FLAC/PDF/JXL files'
    if test (count $argv) -eq 0
        _media_usage
        return 1
    end

    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case optimize
            _media_optimize $argv
        case check
            _media_check $argv
        case fix
            _media_fix $argv
        case convert
            _media_convert $argv
        case '*'
            _media_usage
            return 1
    end
end

function _media_usage
    echo "Usage: media <optimize|check|fix|convert> [options] <file> ..."
    echo
    echo "  optimize [--strip] [--quality N] [--ocr]"
    echo "                    Recompress tif/flac/png/jpg/pdf in place (default: most lossless"
    echo "                    option, metadata kept."
    echo "                    --strip strips metadata from tif/png/jpg"
    echo "                    --quality N recompresses jpg lossily (1-100, recommended 90)."
    echo "                    --ocr runs OCR on pdf pages"
    echo "  check [--fix]     Report warnings/errors using exiftool/flac."
    echo "                    --fix tries to auto-repair any flagged file."
    echo "  fix               Fix corrupt metadata by rebuilding tags from themselves."
    echo "  convert <jxl|png|jpg|flac|webm|pdf> <file> ..."
    echo "                    jpg:  convert images to JPG at a given quality (default 90)."
    echo "                    png:  convert images to PNG and compress with oxipng."
    echo "                    jxl:  convert images to JPEG XL (lossless for jpg source)."
    echo "                    flac: convert audio files to FLAC."
    echo "                    webm: convert mkv to webm (stream copy)."
    echo "                    pdf:  convert images or svgs to a PDF file."
    echo "                          media convert pdf [--ocr|--no-ocr] [output.pdf] <file> ..."
    echo "                          (output.pdf defaults to out.pdf if omitted)"
    echo "                          (OCR on by default, off for svgs)"
end

function _media_optimize
    argparse 'strip' 'quality=' 'ocr' -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: media optimize [--strip] [--quality N] [--ocr] <file> ..." >&2
        return 1
    end

    set -l tif_files
    set -l flac_files
    set -l png_files
    set -l jpg_files
    set -l pdf_files

    for file in $argv
        if not test -f "$file"
            echo "$file is not an existing file. Skipping..." >&2
            continue
        end
        switch (string lower "$file")
            case '*.tif' '*.tiff'
                set -a tif_files "$file"
            case '*.flac'
                set -a flac_files "$file"
            case '*.png'
                set -a png_files "$file"
            case '*.jpg' '*.jpeg'
                set -a jpg_files "$file"
            case '*.pdf'
                set -a pdf_files "$file"
            case '*'
                echo "$file has an unsupported extension. Skipping..." >&2
        end
    end

    if test (count $tif_files) -gt 0
        set -l tif_strip false
        set -l desc "trying LZW then ZIP compression in parallel, keeping whichever is smaller"
        if set -q _flag_strip
            set tif_strip true
            set desc "$desc, stripping metadata"
        end
        echo "=== TIFF: $desc ==="
        for method in lzw zip
            echo "--- pass: $method ---"
            printf '%s\n' $tif_files | PARALLEL_SHELL=fish parallel '
                set -l original (stat -c%s {})
                set -l mode (stat -c%a {})
                set -l tmp (mktemp --suffix=.tif)
                if distrobox_fallback magick {} -compress '$method' "$tmp"
                    if test '$tif_strip' = false
                        distrobox_fallback exiftool -tagsfromfile {} -all:all -overwrite_original -q -q "$tmp"
                    end
                    set -l compressed (stat -c%s "$tmp")
                    if test $compressed -lt $original
                        chmod $mode "$tmp"
                        mv "$tmp" {}
                        echo "Compressed {}: $original -> $compressed bytes"
                    else
                        rm "$tmp"
                        echo "Skipped {}: $original bytes (compressed would be $compressed)"
                    end
                else
                    rm -f "$tmp"
                    echo "Failed to compress {} ('$method'), keeping original" >&2
                end
            '
        end
        set -q _flag_strip; or echo "tip: pass --strip to not keep metadata from these TIFFs."
    end

    if test (count $flac_files) -gt 0
        echo "=== FLAC: recompressing losslessly at level 8 ==="
        distrobox_fallback flac -f8 $flac_files
    end

    if test (count $png_files) -gt 0
        set -l png_args -o 4 --alpha
        set -l desc "lossless recompression"
        if set -q _flag_strip
            set -a png_args -s
            set desc "$desc, stripping metadata"
        end
        echo "=== PNG: $desc ==="
        distrobox_fallback oxipng $png_args $png_files
        set -q _flag_strip; or echo "tip: pass --strip to also remove metadata from these PNGs."
    end

    if test (count $jpg_files) -gt 0
        set -l jpg_args
        set -l desc "lossless recompression only"
        if set -q _flag_quality
            set -a jpg_args -m$_flag_quality
            set desc "lossy recompression, with quality $_flag_quality"
        end
        if set -q _flag_strip
            set -a jpg_args -s
            set desc "$desc, stripping metadata"
        end
        echo "=== JPG: $desc ==="
        distrobox_fallback jpegoptim $jpg_args $jpg_files
        set -l tips
        set -q _flag_quality; or set -a tips "--quality N (try ~90) for lossy recompression"
        set -q _flag_strip; or set -a tips "--strip to remove metadata"
        test (count $tips) -gt 0; and echo "tip: pass "(string join ', or ' -- $tips)"."
    end

    if test (count $pdf_files) -gt 0
        set -l ocr_args --pages 999
        set -l desc "optimize level 3 only, no OCR"
        if set -q _flag_ocr
            set ocr_args --skip-text
            set desc "optimize level 3, OCR pages without a text layer"
        end
        echo "=== PDF: $desc ==="
        for file in $pdf_files
            set -l mode (stat -c%a $file)
            set -l tmp (mktemp --suffix=.pdf)
            if distrobox_fallback ocrmypdf -l jpn+eng+deu $file $tmp --clean --optimize 3 $ocr_args
                chmod $mode $tmp
                mv $tmp $file
            else
                rm -f $tmp
                echo "Failed to optimize $file, keeping original" >&2
            end
        end
        set -q _flag_ocr; or echo "tip: pass --ocr to also OCR pages without an existing text layer."
    end
end

function _media_check
    argparse 'fix' -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: media check [--fix] <file> ..." >&2
        return 1
    end

    set -l bad_count 0

    for file in $argv
        if not test -f "$file"
            echo "$file is not an existing file. Skipping..." >&2
            continue
        end

        if string match -qi '*.flac' "$file"
            if not distrobox_fallback flac -t -s "$file" 2>/dev/null
                set bad_count (math $bad_count + 1)
                echo "ISSUE: $file (flac integrity check failed)"
            end
        else
            set -l issues (distrobox_fallback exiftool -warning -error -a -q -q -- "$file")
            if test -n "$issues"
                set bad_count (math $bad_count + 1)
                echo "ISSUE: $file"
                printf '  %s\n' $issues
                if set -q _flag_fix
                    _media_fix "$file"
                end
            end
        end
    end

    if test $bad_count -eq 0
        echo "All good, no issues found."
    else
        echo "$bad_count file(s) with issues."
        set -q _flag_fix; or echo "tip: pass --fix to try automatically repairing these."
    end
end

function _media_fix
    if test (count $argv) -eq 0
        echo "Usage: media fix <file> ..." >&2
        return 1
    end

    for file in $argv
        if not test -f "$file"
            echo "$file is not an existing file. Skipping..." >&2
            continue
        end
        if string match -qi '*.flac' "$file"
            echo "Reencoding: $file"
            distrobox_fallback flac -f -8 -F "$file"
        else
            echo "Fixing metadata: $file"
            distrobox_fallback exiftool -all= -tagsfromfile @ -all:all -unsafe "$file"
        end
    end
end

function _media_convert
    if test (count $argv) -eq 0
        echo "Usage: media convert <jxl|png|jpg|flac|webm|pdf> <file> ..." >&2
        return 1
    end

    set -l type $argv[1]
    set -e argv[1]

    switch $type
        case jxl
            _media_convert_jxl $argv
        case png
            _media_convert_png $argv
        case jpg
            _media_convert_jpg $argv
        case flac
            _media_convert_flac $argv
        case webm
            _media_convert_webm $argv
        case pdf
            _media_convert_pdf $argv
        case '*'
            echo "Unknown convert type '$type' (expected jxl, png, jpg, flac, webm, or pdf)" >&2
            return 1
    end
end

function _media_convert_jxl --description 'Convert images to JPEG XL (lossless for jpg source, near-lossless otherwise)'
    for file in $argv
        if test -f $file
            set file_out (path change-extension '' $file).jxl
            if test -e $file_out
                echo "$file_out already exists. Skipping $file..." >&2
                continue
            end
            echo "Converting $file to $file_out"

            # if the file is a jpeg, convert to jxl losslessly
            if string match --quiet --regex -i '\.jpe?g$' $file
                distrobox_fallback cjxl -e 7 --lossless_jpeg=1 -d 0 "$file" "$file_out"
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

function _media_convert_png --description 'Convert images to PNG and compress with oxipng'
    if string match --quiet --regex '^-' "$argv[2]" || test -z "$argv[2]"
        # allow setting custom arguments like --strip safe

        set file $argv[1]
        set file_out $file
        if not string match --quiet --regex -i '\.png$' $file
            set file_out (path change-extension '' $file).png
            if test -e $file_out
                echo "$file_out already exists. Skipping $file..." >&2
                return
            end
            echo "Converting $file to $file_out"
            distrobox_fallback magick $file -auto-orient $file_out
        end

        echo "Compressing $file_out"

        distrobox_fallback oxipng -o 6 $argv[2..] --alpha $file_out
    else
        echo "Processing multiple files..."
        for file in $argv[1..]
            if test -f $file
                _media_convert_png $file
            else
                echo "$file is not an existing file. Skipping..."
            end
        end
    end
end

function _media_convert_pdf --description 'Convert images or svgs to a PDF file'
    argparse 'ocr' 'no-ocr' -- $argv
    or return 1

    if test (count $argv) -lt 1
        echo "Usage: media convert pdf [--ocr|--no-ocr] [output.pdf] <file> ..." >&2
        return 1
    end

    set -l out out.pdf
    if string match --quiet --regex -i '\.pdf$' $argv[1]
        set out $argv[1]
        set -e argv[1]
    end

    if test (count $argv) -eq 0
        echo "Usage: media convert pdf [--ocr|--no-ocr] [output.pdf] <file> ..." >&2
        return 1
    end

    if test -e $out
        echo "$out already exists. Aborting to avoid overwriting it." >&2
        return 1
    end

    set -l is_svg false
    string match --quiet --regex -i '\.svg$' $argv[1]; and set is_svg true

    # --pages 999 is the most reliable way to skip OCR entirely while still running the rest of the pipeline
    set -l skip_ocr false
    if test "$is_svg" = true
        set -q _flag_ocr; or set skip_ocr true
    end
    set -q _flag_no_ocr; and set skip_ocr true

    set -l ocr_args
    set -l desc "OCR pages without a text layer"
    if test "$skip_ocr" = true
        set ocr_args --pages 999
        set desc "no OCR"
    end

    set -l kind "image(s)"
    test "$is_svg" = true; and set kind "svg(s)"
    echo "=== Combining "(count $argv)" $kind into $out ($desc) ==="

    if test "$is_svg" = true
        distrobox_fallback rsvg-convert -f pdf $argv | distrobox_fallback ocrmypdf - $out --optimize 3 $ocr_args
    else
        distrobox_fallback img2pdf $argv | distrobox_fallback ocrmypdf - $out --optimize 3 $ocr_args
    end

    if test "$is_svg" = true
        set -q _flag_ocr; or echo "tip: pass --ocr to force OCR anyway (usually unnecessary, svg text is already real text)."
    else
        set -q _flag_no_ocr; or echo "tip: pass --no-ocr to skip OCR and just bundle the images."
    end
end

function _media_convert_jpg --description '(Re)compress any jpg/jpeg file via imagemagick at a given quality'
    if string match --quiet --regex '^[0-9][0-9]?$' "$argv[2]" || test -z "$argv[2]"
        # allow setting custom arguments like --strip

        set -l file $argv[1]
        set -l quality $argv[2]
        test -z "$quality"; and set quality 90

        if not string match --quiet --regex -i '\.jpe?g$' $file
            echo "$file is not a jpg/jpeg file. Skipping..."
            return
        end

        set -l file_out (path change-extension '' $file)-out.jpg

        if test -e $file_out
            echo "$file_out already exists. Skipping $file..." >&2
            return
        end

        echo "Compressing $file to $file_out with quality $quality"

        distrobox_fallback magick $file -auto-orient -quality $quality% -interlace Plane -define jpeg:dct-method=float -colorspace sRGB $argv[3..] $file_out
        # -resize 2000x2000\>
    else
        echo "Processing multiple files..."
        for file in $argv[1..]
            if test -f $file
                _media_convert_jpg $file
            else
                echo "$file is not an existing file. Skipping..."
            end
        end
    end
end

function _media_convert_flac --description 'Convert audio files to FLAC using ffmpeg'
    for file in $argv
        if test -f $file
            set file_out (path change-extension '' $file)-out.flac
            if not string match --quiet --regex -i '\.flac$' $file
                set file_out (path change-extension '' $file).flac
            end

            if test -e $file_out
                echo "$file_out already exists. Skipping $file..." >&2
                continue
            end

            echo "Converting $file to $file_out"
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $file -c:a flac -compression_level 8 $file_out
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end

function _media_convert_webm --description 'Convert mkv to webm (stream copy)'
    for file in $argv
        if test -f $file
            set file_out (path change-extension '' $file).webm
            if test -e $file_out
                echo "$file_out already exists. Skipping $file..." >&2
                continue
            end
            echo "Converting $file to $file_out"
            distrobox_fallback ffmpeg -hide_banner -loglevel panic -i $file -c copy -map_metadata 0 $file_out
        else
            echo "$file is not an existing file. Skipping..."
        end
    end
end
