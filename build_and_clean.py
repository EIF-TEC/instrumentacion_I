#!/usr/bin/env python3
"""
LaTeX build wrapper that automatically cleans up compilation artifacts.
Usage: python build_and_clean.py <file.tex>
"""

import subprocess
import sys
from pathlib import Path

def build_and_clean(tex_file):
    """Build PDF and remove all LaTeX compilation artifacts."""
    
    tex_path = Path(tex_file)
    if not tex_path.exists():
        print(f"Error: {tex_file} not found")
        return 1
    
    base_name = tex_path.stem
    base_dir = tex_path.parent
    
    # Run latexmk
    print(f"Building {tex_file}...")
    result = subprocess.run([
        'latexmk', '-pdf', '-interaction=nonstopmode', '-file-line-error', tex_file
    ], cwd=base_dir)
    
    if result.returncode != 0:
        print(f"Build failed with code {result.returncode}")
    else:
        print(f"Build succeeded: {base_name}.pdf")
    
    # Clean up artifacts - must do this before latexmk -C or it removes PDF
    artifacts = [
        'aux', 'bbl', 'bcf', 'blg', 'fdb_latexmk', 'fls',
        'log', 'nav', 'out', 'snm', 'toc', 'xdv',
        'run.xml', 'synctex.gz'
    ]
    
    print("Cleaning artifacts...")
    removed = 0
    
    # Remove standard extensions
    for ext in artifacts:
        artifact = base_dir / f"{base_name}.{ext}"
        if artifact.exists():
            artifact.unlink()
            removed += 1
            print(f"  Removed: {artifact.name}")
    
    if removed > 0:
        print(f"Cleaned {removed} artifact files")
    
    return result.returncode

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python build_and_clean.py <file.tex>")
        sys.exit(1)
    
    sys.exit(build_and_clean(sys.argv[1]))
