function flacseektabler --description 'Check and add seektables of FLAC files'
    for file in **.flac
        set -l total_samples (distrobox_fallback metaflac --show-total-samples "$file" 2>/dev/null)
        set -l sample_rate (distrobox_fallback metaflac --show-sample-rate "$file" 2>/dev/null)

        if test -z "$total_samples" -o -z "$sample_rate" -o "$sample_rate" -eq 0
            echo "Warning: Invalid sample data (total_samples: '$total_samples', sample_rate: '$sample_rate') for: $file" >&2
            continue
        end        
        set -l duration (math $total_samples / $sample_rate)


        set -l num_seekpoints (distrobox_fallback metaflac --list --block-type=SEEKTABLE "$file" 2>/dev/null | grep "seek points:" | awk '{print $3}')
        if string match -r '^[0-9]+$' "$num_seekpoints" >/dev/null
          if test "$num_seekpoints" -gt 0
              set -l interval (math $duration / $num_seekpoints)
              echo (printf "%.2f" "$interval") "  $file"

              # Check if interval is between 5 and 11 seconds
              if test (echo "$interval > 6 && $interval < 11" | bc -l) -eq 1
                  continue
              end
          end
        end

        distrobox_fallback metaflac --remove --block-type=SEEKTABLE "$file" 2>/dev/null

        echo "Adding 10s seektable to: $file"
        distrobox_fallback metaflac --add-seekpoint=10s "$file"
    end
    echo "Done!"
end
