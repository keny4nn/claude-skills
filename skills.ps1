# ============================================================================
#  skills.ps1 - gere TES skills Claude sur CE PC (install + repair + sync).
#  Garantit le bon fonctionnement ET l'activation de tous les skills.
#
#  Usage :
#    .\skills.ps1            -> installe les skills du repo dans ~/.claude/skills,
#                              repare les skills casses (aplati les plugin-repos),
#                              et fait un diagnostic clair.
#    .\skills.ps1 -Push      -> envoie TES skills locaux VERS le repo (commit+push)
#                              pour que l'autre PC les recupere.
#    .\skills.ps1 -Doctor    -> diagnostic seul, n'installe / ne copie rien.
#
#  Lance ce script (ou le bouton SYNC) a chaque arrivee sur un PC.
#  Apres l'install : FERME et ROUVRE Claude Code pour qu'il voie les skills.
#  (ASCII uniquement : compatible Windows PowerShell 5.1 sans souci d'encodage.)
# ============================================================================
param([switch]$Push, [switch]$Doctor)
$ErrorActionPreference = 'Stop'
$skills = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force $skills | Out-Null

function Has-Skill($dir) { Test-Path (Join-Path $dir 'SKILL.md') }

# --- localiser le repo : soit le dossier du script (clone), soit telecharger ---
$repo = $PSScriptRoot
$haveClone = $repo -and (Test-Path (Join-Path $repo '.git'))
if (-not $repo -or -not (Get-ChildItem $repo -Directory -EA SilentlyContinue | Where-Object { Has-Skill $_.FullName })) {
  Write-Host "Telechargement du repo claude-skills..." -ForegroundColor Cyan
  $zip = Join-Path $env:TEMP "claude-skills.zip"; $ext = Join-Path $env:TEMP "claude-skills-ext"
  Invoke-WebRequest "https://github.com/keny4nn/claude-skills/archive/refs/heads/master.zip" -OutFile $zip
  if (Test-Path $ext) { Remove-Item -Recurse -Force $ext }
  Expand-Archive $zip $ext -Force
  $repo = (Get-ChildItem $ext -Directory | Select-Object -First 1).FullName
}

# ============================ MODE PUSH ============================
if ($Push) {
  if (-not $haveClone) { Write-Host "[X] -Push exige le repo clone (lance depuis Desktop\claude-skills)." -ForegroundColor Red; exit 1 }
  $n = 0
  Get-ChildItem $skills -Directory | Where-Object { Has-Skill $_.FullName } | ForEach-Object {
    Copy-Item $_.FullName -Destination $repo -Recurse -Force; $n++
  }
  Push-Location $repo
  git add -A | Out-Null
  git commit -q -m ("skills snapshot depuis {0} ({1} skills)" -f $env:COMPUTERNAME, $n) 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) {
    git push -q 2>$null | Out-Null
    Write-Host ("[OK] {0} skills locaux pousses vers le repo." -f $n) -ForegroundColor Green
  } else {
    Write-Host "Rien de nouveau a pousser." -ForegroundColor Yellow
  }
  Pop-Location
  return
}

# ====================== MODE INSTALL (defaut) ======================
$installed = 0
if (-not $Doctor) {
  Get-ChildItem $repo -Directory | Where-Object { $_.Name -notlike '.*' -and (Has-Skill $_.FullName) } | ForEach-Object {
    Copy-Item $_.FullName -Destination $skills -Recurse -Force; $installed++
  }
}

# --- validation + reparation de TOUT ~/.claude/skills ---
# Un dir sans SKILL.md racine = soit un "plugin-repo" (skills enterres d'un cran
# sous skills/ ou .claude/skills/), soit du bruit. On aplatit SEULEMENT les
# enfants directs d'un dossier skills/ (pas en profondeur), et on n'ecrase jamais
# un skill deja present -> aucun doublon, aucun import de sous-exemples.
$fixed = @(); $broken = @()
foreach ($d in (Get-ChildItem $skills -Directory)) {
  if (Has-Skill $d.FullName) { continue }
  $skRoots = @((Join-Path $d.FullName 'skills'), (Join-Path $d.FullName '.claude\skills')) | Where-Object { Test-Path $_ }
  $moved = @()
  foreach ($r in $skRoots) {
    Get-ChildItem $r -Directory -EA SilentlyContinue | Where-Object { Has-Skill $_.FullName } | ForEach-Object {
      if (-not (Test-Path (Join-Path $skills $_.Name))) { Copy-Item $_.FullName -Destination $skills -Recurse -Force; $moved += $_.Name }
    }
  }
  if ($moved)            { $fixed  += ("{0} -> {1}" -f $d.Name, ($moved -join '/')) }
  elseif (-not $skRoots) { $broken += $d.Name }   # ni SKILL.md ni sous-skills = vrai bruit
}
$active = (Get-ChildItem $skills -Directory | Where-Object { Has-Skill $_.FullName }).Count

# ============================ RAPPORT ============================
Write-Host ""
Write-Host "=== SKILLS ($env:COMPUTERNAME) ===" -ForegroundColor Cyan
if (-not $Doctor) { Write-Host ("  installes depuis le repo      : {0}" -f $installed) -ForegroundColor Green }
Write-Host ("  actifs (SKILL.md a la racine) : {0}" -f $active) -ForegroundColor Green
if ($fixed)  { Write-Host ("  repares (plugin-repos aplatis): {0}" -f ($fixed -join ', ')) -ForegroundColor Yellow }
if ($broken) { Write-Host ("  [!] sans SKILL.md (NE chargeront PAS): {0}" -f ($broken -join ', ')) -ForegroundColor Red }
else         { Write-Host "  OK - aucun skill casse." -ForegroundColor Green }
Write-Host ""
Write-Host "-> FERME et ROUVRE Claude Code pour charger les skills." -ForegroundColor Cyan
