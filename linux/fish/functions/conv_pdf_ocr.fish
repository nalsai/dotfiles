function conv_pdf_ocr --description 'Compress and (don\'t) OCR PDF files'
    for file in $argv[1..]
        if test -f $file && string match --quiet --regex '\.pdf$' $file
            set file_out (path change-extension '' $file)-out.pdf
            distrobox_fallback ocrmypdf -l jpn+eng+deu $file $file_out --clean --optimize 3 --skip-text #--pages 99999 #--deskew 
        else
            echo "$file is either not a PDF or doesn't exist. Skipping..."
        end
    end
end
