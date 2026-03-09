#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
export XDG_CACHE_HOME="/tmp/r4ds-sports-site-quarto-cache"
mkdir -p "${XDG_CACHE_HOME}"

for qmd in slides-src/session*/index.qmd; do
  output_dir="$(pwd)/static/slides"
  mkdir -p "${output_dir}"
  quarto render "$qmd" --output-dir "$output_dir"
done
