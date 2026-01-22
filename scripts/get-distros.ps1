# WSL Distribution List Helper
# Returns clean distribution names without UTF-16 encoding issues
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File get-distros.ps1 [-Running]

param(
    [switch]$Running
)

if ($Running) {
    $distros = (wsl -l -q --running) -replace [char]0
}
else {
    $distros = (wsl -l -q) -replace [char]0
}

$distros | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
