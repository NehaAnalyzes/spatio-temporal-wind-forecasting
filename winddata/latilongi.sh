#!/usr/bin/env bash
# Usage: ./extract_second_line.sh paths.txt  > second_lines.txt

set -euo pipefail

input_list="$1"

# read the list line‑by‑line
# field 1 = path (in quotes); we ignore field 2
while IFS= read -r line; do
    # grab the first field, strip surrounding quotes
    file_path=$(awk '{print $1}' <<< "$line" | tr -d '"')

    # if the file exists, print its second line; otherwise warn
    if [[ -f $file_path ]]; then
        sed -n '2p' "$file_path"
    else
        echo "Warning: file not found -> $file_path" >&2
    fi
done < "$input_list"

