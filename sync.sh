#!/usr/bin/env bash
mutagen sync create \
  --name "${USER}-sd-lab-c" \
  -c mutagen.yml \
  ./ \
  vscode@dev.mistercricro8.top:28009:/home/vscode/sd-2026-lab-c-grupo-3
