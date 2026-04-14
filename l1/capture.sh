#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo "Usage: capture.sh <output-file> <command1> [command2] [...]"
    echo "Example: ./capture.sh out 'eza -lah' 'cat sample.c'"
    exit 1
fi

output_file="$1"
commands=("${@:2}")

esc=$'\e'
reset="${esc}[0m"
green="${esc}[38;5;114m"
blue="${esc}[38;5;111m"
flamingo="${esc}[38;5;217m"

temp_output=$(mktemp)

for command_name in "${commands[@]}"; do
    read -r -a words <<< "$command_name"
    first_word="${words[0]}"
    rest_words=("${words[@]:1}")

    colored_command="${blue}${first_word}${reset}"

    if [ "${#rest_words[@]}" -gt 0 ]; then
        joined_rest="${rest_words[*]}"
        colored_command="${colored_command} ${flamingo}${joined_rest}${reset}"
    fi

    printf "%s❯ %s\n" "$green" "$colored_command" >> "$temp_output"

    eval "$command_name" >> "$temp_output" 2>&1
done

cat "$temp_output" | tee lastcmd.log | freeze \
    --width 1000 \
    --theme catppuccin-mocha \
    --font.family "CaskaydiaMono Nerd Font" \
    --output "$output_file.svg" \
    --language ansi

inkscape -w 2048 "$output_file.svg" -o "$output_file.png"

rm "$output_file.svg"
rm "$temp_output"
