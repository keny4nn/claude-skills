# ============================================================
# Setup tout-en-un des skills Claude sur un nouveau PC (Monster, etc.)
# Usage (a coller dans PowerShell) :
#   irm https://raw.githubusercontent.com/keny4nn/claude-skills/master/setup-monster.ps1 | iex
# Aucun git requis (telechargement ZIP). Reexecuter pour mettre a jour.
# ============================================================
$ErrorActionPreference = 'Stop'
Write-Host "=== Installation des skills Claude sur ce PC ===" -ForegroundColor Cyan

# 1) dossier des skills personnels
$skills = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force -Path $skills | Out-Null

# 2) telecharger le repo en ZIP (pas besoin de git ni de login -> repo public)
$zip = Join-Path $env:TEMP "claude-skills.zip"
$ext = Join-Path $env:TEMP "claude-skills-ext"
Write-Host "Telechargement des skills depuis GitHub..." -ForegroundColor Cyan
Invoke-WebRequest "https://github.com/keny4nn/claude-skills/archive/refs/heads/master.zip" -OutFile $zip
if (Test-Path $ext) { Remove-Item -Recurse -Force $ext }
Expand-Archive $zip $ext -Force
$src = (Get-ChildItem $ext -Directory | Select-Object -First 1).FullName   # claude-skills-master

# 3) copier chaque skill dans ~/.claude/skills (sans toucher au reste)
Get-ChildItem $src -Directory | ForEach-Object {
    Copy-Item $_.FullName -Destination $skills -Recurse -Force
}
$names = (Get-ChildItem $src -Directory | Select-Object -Expand Name) -join ", "
Write-Host "Skills installes -> $skills" -ForegroundColor Green
Write-Host "  ($names)"

# 4) dependances du skill 'watch' (video YouTube) : yt-dlp + ffmpeg
Write-Host "Installation des outils video (yt-dlp + ffmpeg)..." -ForegroundColor Cyan
$pyok = $false
foreach ($p in @('py','python','python3')) {
    try { & $p -m pip install --quiet --disable-pip-version-check yt-dlp; $pyok = $true; break } catch {}
}
if (-not $pyok) { Write-Host "  (Python introuvable -> installe Python puis 'py -m pip install yt-dlp')" -ForegroundColor Yellow }
try { winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements | Out-Null; Write-Host "  ffmpeg OK" -ForegroundColor Green }
catch { Write-Host "  (ffmpeg : installe-le via 'winget install Gyan.FFmpeg' si winget manque)" -ForegroundColor Yellow }

# 5) suite
Write-Host ""
Write-Host "=== TERMINE ===" -ForegroundColor Green
Write-Host "1) FERME et ROUVRE Claude Code -> il verra les skills (canary, watch, council, ...)." -ForegroundColor White
Write-Host "2) Pour Superpowers (routeur de skills), tape dans Claude :" -ForegroundColor White
Write-Host "      /plugin install superpowers@claude-plugins-official" -ForegroundColor Cyan
Write-Host "3) (ffmpeg) si 'watch' rale au 1er essai -> rouvre le terminal une fois." -ForegroundColor White
