#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo "Usage: capture.sh <output-file> <command> [ms:input] [...]"
    exit 1
fi

output_file="$1"
shift
args=("$@")

esc=$'\e'
reset="${esc}[0m"
green="${esc}[38;5;114m"
blue="${esc}[38;5;111m"
flamingo="${esc}[38;5;217m"

mkdir -p capture_logs

image_name=$(basename "$output_file")
log_file="capture_logs/${image_name}.log"

temp_output=$(mktemp)

i=0
while [ $i -lt ${#args[@]} ]; do
    command_name="${args[$i]}"

    read -r -a words <<< "$command_name"
    first_word="${words[0]}"
    rest_words=("${words[@]:1}")
    colored_command="${blue}${first_word}${reset}"
    [ "${#rest_words[@]}" -gt 0 ] && colored_command="${colored_command} ${flamingo}${rest_words[*]}${reset}"

    printf "%s❯ %s\n" "$green" "$colored_command" >> "$temp_output"

    inputs=()
    while [[ $i+1 -lt ${#args[@]} && "${args[$((i+1))]}" =~ ^[0-9]+: ]]; do
        i=$((i+1))
        inputs+=("${args[$i]}")
    done

    (
        if [ ${#inputs[@]} -gt 0 ]; then
            for item in "${inputs[@]}"; do
                ms="${item%%:*}"
                text="${item#*:}"
                delay=$(awk "BEGIN {print $ms/1000}")
                sleep "$delay"
                echo "$text"
            done
        fi
        sleep 0.1
    ) | script -qec "$command_name" /dev/null | tr -d '\r' >> "$temp_output" 2>&1

    i=$((i+1))
done

cat "$temp_output" | tee "$log_file" | freeze \
    --width 1000 \
    --theme catppuccin-mocha \
    --font.family "CaskaydiaMono Nerd Font" \
    --output "$output_file.svg" \
    --language ansi

inkscape -w 2048 "$output_file.svg" -o "$output_file.png"
rm "$output_file.svg" "$temp_output"