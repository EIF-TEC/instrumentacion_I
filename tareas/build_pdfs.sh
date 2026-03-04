#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

cleanup_extensions=(
  aux
  bbl
  bcf
  blg
  fdb_latexmk
  fls
  log
  out
  run.xml
  synctex.gz
  toc
  xdv
)

build_tex() {
  local tex="$1"
  local cmd=(latexmk -xelatex -interaction=nonstopmode -halt-on-error "$tex")

  if "${cmd[@]}"; then
    return 0
  fi

  echo "[warn] latexmk falló para $tex. Limpiando estado previo y reintentando..."
  latexmk -C "$tex" >/dev/null 2>&1 || true
  rm -f -- "${tex%.tex}.fdb_latexmk" "${tex%.tex}.fls"
  "${cmd[@]}"
}

for tex in t*.tex; do
  if [[ -f "$tex" ]]; then
    echo "[build] $tex"
    build_tex "$tex"

    base="${tex%.tex}"
    for ext in "${cleanup_extensions[@]}"; do
      rm -f -- "${base}.${ext}"
    done
  fi
done

echo "PDF update completed."
