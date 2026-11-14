param(
  [Parameter(Mandatory = $true)]
  [string]$TargetDir,

  [string]$SchoolFullName = "示範國民中學",
  [string]$SchoolShortName = "示範國中",
  [string]$SpreadsheetId = "REPLACE_WITH_YOUR_CLUB_SPREADSHEET_ID",
  [string]$ScoreSpreadsheetId = "",
  [string]$GasWebappUrl = "https://script.google.com/macros/s/REPLACE_WITH_YOUR_DEPLOYMENT_ID/exec",
  [string]$DefaultSalt = "SCHOOL_CLUB_SALT_2026"
)

$ErrorActionPreference = "Stop"
$TemplateDir = Join-Path $PSScriptRoot "..\resources\template"

if (-not (Test-Path $TemplateDir)) {
  throw "找不到範本目錄：$TemplateDir"
}

New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "tests") | Out-Null
Copy-Item (Join-Path $TemplateDir "Code.gs") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir "index.html") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir "appsscript.json") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir ".claspignore") $TargetDir -Force
Copy-Item (Join-Path $TemplateDir "tests\club_backend.test.cjs") (Join-Path $TargetDir "tests") -Force

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$EffectiveScoreId = if ($ScoreSpreadsheetId -and $ScoreSpreadsheetId.Trim() -ne "") { $ScoreSpreadsheetId.Trim() } else { "REPLACE_WITH_SCORE_DB_ID" }

# 1. 更新 Code.gs
$codePath = Join-Path $TargetDir "Code.gs"
$code = [System.IO.File]::ReadAllText($codePath, [System.Text.Encoding]::UTF8)
$code = $code.Replace("示範國民中學", $SchoolFullName)
$code = $code.Replace("示範國中", $SchoolShortName)
$code = $code.Replace("REPLACE_WITH_YOUR_CLUB_SPREADSHEET_ID", $SpreadsheetId)
$code = $code.Replace("REPLACE_WITH_SCORE_DB_ID", $EffectiveScoreId)
$code = $code.Replace("SCHOOL_CLUB_SALT_2026", $DefaultSalt)
[System.IO.File]::WriteAllText($codePath, $code, $Utf8NoBom)

# 2. 更新 index.html
$htmlPath = Join-Path $TargetDir "index.html"
$html = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)
$html = $html.Replace("示範國民中學", $SchoolFullName)
$html = $html.Replace("示範國中", $SchoolShortName)
$html = $html.Replace("REPLACE_WITH_YOUR_CLUB_SPREADSHEET_ID", $SpreadsheetId)
$html = $html.Replace("https://script.google.com/macros/s/REPLACE_WITH_YOUR_DEPLOYMENT_ID/exec", $GasWebappUrl)
[System.IO.File]::WriteAllText($htmlPath, $html, $Utf8NoBom)

# 3. 同步調整測試腳本內的唯讀來源試算表 Mock ID
$testPath = Join-Path $TargetDir "tests\club_backend.test.cjs"
$testJs = [System.IO.File]::ReadAllText($testPath, [System.Text.Encoding]::UTF8)
$testJs = $testJs.Replace("REPLACE_WITH_SCORE_DB_ID", $EffectiveScoreId)
[System.IO.File]::WriteAllText($testPath, $testJs, $Utf8NoBom)

Write-Output "SCAFFOLD_OK: $TargetDir ($SchoolFullName / $SchoolShortName)"
