# PowerShell script to remove LaTeX compilation artifacts
# Keeps only .tex and .pdf files

param(
    [string]$Directory = ".",
    [switch]$Recursive
)

$artifacts = @(
    'aux', 'bbl', 'bcf', 'blg', 'fdb_latexmk', 'fls', 
    'log', 'nav', 'out', 'run.xml', 'snm', 'synctex.gz', 'toc', 'xdv'
)

$params = if ($Recursive) { @{ -Recurse = $true } } else { @{} }

$removed = 0
foreach ($artifact in $artifacts) {
    $pattern = "*.$artifact"
    $files = Get-ChildItem -Path $Directory @params -Include $pattern -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
        $removed++
        Write-Host "Removed: $($file.Name)"
    }
}

Write-Host "`nCleaned up $removed artifact files from $Directory"
