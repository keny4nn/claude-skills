# ============================================================
#  Bootstrap des skills Claude sur un PC (one-liner) :
#    irm https://raw.githubusercontent.com/keny4nn/claude-skills/master/setup-monster.ps1 | iex
#  -> telecharge le repo, lance skills.ps1 (install + reparation + rapport),
#     puis installe les outils du skill 'watch' (yt-dlp + ffmpeg).
#  Reexecuter pour mettre a jour. Aucun git requis (ZIP public).
#  Install locale propre / pousser tes skills : Desktop\claude-skills\skills.ps1
# ============================================================
$ErrorActionPreference = 'Continue'
$zip = Join-Path $env:TEMP "claude-skills.zip"; $ext = Join-Path $env:TEMP "claude-skills-ext"
Write-Host "Telechargement du repo claude-skills..." -ForegroundColor Cyan
Invoke-WebRequest "https://github.com/keny4nn/claude-skills/archive/refs/heads/master.zip" -OutFile $zip
if (Test-Path $ext) { Remove-Item -Recurse -Force $ext }
Expand-Archive $zip $ext -Force
$repo = (Get-ChildItem $ext -Directory | Select-Object -First 1).FullName

# install + reparation + rapport (logique unique dans skills.ps1)
& "$repo\skills.ps1"

# outils du skill 'watch' (video YouTube) : yt-dlp + ffmpeg
Write-Host "Outils video du skill 'watch' (yt-dlp + ffmpeg)..." -ForegroundColor Cyan
$pyok = $false
foreach ($p in @('py','python','python3')) {
  try { & $p -m pip install --quiet --disable-pip-version-check yt-dlp; $pyok = $true; break } catch {}
}
if (-not $pyok) { Write-Host "  (Python introuvable -> 'py -m pip install yt-dlp')" -ForegroundColor Yellow }
try { winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements --disable-interactivity | Out-Null; Write-Host "  ffmpeg OK" -ForegroundColor Green }
catch { Write-Host "  (ffmpeg : 'winget install Gyan.FFmpeg')" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=== TERMINE === FERME et ROUVRE Claude Code." -ForegroundColor Green
Write-Host "(Optionnel) routeur de skills : /plugin install superpowers@claude-plugins-official" -ForegroundColor White
