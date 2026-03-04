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
  lof
  lot
  out
  run.xml
  synctex.gz
  toc
  xdv
)

guide_tex_files=()

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

cleanup_base() {
  local base="$1"
  for ext in "${cleanup_extensions[@]}"; do
    rm -f -- "${base}.${ext}"
  done
}

discover_guides() {
  local tex=""
  for tex in *.tex; do
    [[ -f "$tex" ]] || continue
    [[ "$tex" == "00_instructivo.tex" ]] && continue
    if [[ "$tex" =~ ^[0-9]+_.+\.tex$ ]]; then
      guide_tex_files+=("$tex")
    fi
  done

  if [[ ${#guide_tex_files[@]} -gt 0 ]]; then
    local sorted=()
    while IFS= read -r tex; do
      sorted+=("$tex")
    done < <(printf '%s\n' "${guide_tex_files[@]}" | sort -t '_' -k1,1n -k2,2)
    guide_tex_files=("${sorted[@]}")
  fi
}

generate_instructivo_autolist() {
  local list_file="__labs_autolist.tex"
  {
    echo "% Archivo autogenerado por build_pdfs.sh"
    echo "% Incluye todas las practicas detectadas en guide/"
    if [[ ${#guide_tex_files[@]} -eq 0 ]]; then
      echo "% No se detectaron practicas."
    else
      local tex=""
      for tex in "${guide_tex_files[@]}"; do
        printf '\\input{%s}\n' "${tex%.tex}"
      done
    fi
  } > "$list_file"
}

build_single_guide() {
  local tex="$1"
  local base="${tex%.tex}"
  local num="${tex%%_*}"
  local chapter=$((10#$num))
  local wrapper="__build_${base}.tex"
  local wrapper_base="${wrapper%.tex}"

  cat > "$wrapper" <<EOF
\\documentclass[12pt,letterpaper]{report}
\\makeatletter
\\def\\input@path{{../common/}{../guide/}{../data/}{../code/}}
\\makeatother
\\input{preamble}
\\input{arduinoLanguage.tex}
\\usepackage{csvsimple}
\\usepackage{geometry}
\\geometry{left=18mm,right=18mm,top=21mm,bottom=21mm,headheight=15pt}
\\setlength\\parindent{0pt}
\\renewcommand{\\labelenumi}{\\alph{enumi}.}
\\usepackage{fancyhdr}
\\pagestyle{fancy}
\\lhead{Instructivo de Laboratorio de Instrumentación I}
\\rhead{\\begin{picture}(0,0) \\put(-60,0){\\includegraphics[width=20mm]{logo.png}} \\end{picture}}
\\newcommand{\\obj}{Objetivos}
\\newcommand{\\mat}{Materiales y equipo}
\\newcommand{\\pro}{Procedimiento}
\\newcommand{\\capacidad}{Al finalizar este laboratorio el estudiante estará en capacidad de:}
\\newcommand{\\antesde}{Antes de empezar el laboratorio presente el siguiente cuestionario lleno.}
\\addto\\captionsspanish{\\renewcommand{\\chaptername}{Laboratorio}}
\\addto\\captionsspanish{\\renewcommand{\\tablename}{Tabla}}
\\begin{document}
\\setcounter{chapter}{$((chapter - 1))}
\\input{${base}}
\\printbibliography
\\end{document}
EOF

  echo "[build] $tex -> ${base}.pdf"
  build_tex "$wrapper"
  mv -f -- "${wrapper_base}.pdf" "${base}.pdf"

  cleanup_base "$wrapper_base"
  rm -f -- "$wrapper"
}

discover_guides
generate_instructivo_autolist

if [[ ${#guide_tex_files[@]} -eq 0 ]]; then
  echo "[warn] No se detectaron practicas con el patron N_nombre.tex"
else
  for tex in "${guide_tex_files[@]}"; do
    build_single_guide "$tex"
  done
fi

if [[ -f "00_instructivo.tex" ]]; then
  echo "[build] 00_instructivo.tex"
  build_tex "00_instructivo.tex"
  cleanup_base "00_instructivo"
fi

echo "Guide PDFs update completed."
