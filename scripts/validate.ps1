$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    foreach ($tool in @('stylua', 'selene', 'rojo')) {
        if (!(Test-Path -LiteralPath ".tools/$tool/$tool.exe")) { throw "Missing $tool; run scripts/install-tools.ps1" }
    }
    & ./.tools/stylua/stylua.exe --check src
    if ($LASTEXITCODE -ne 0) { throw 'StyLua failed' }
    & ./.tools/selene/selene.exe src
    if ($LASTEXITCODE -ne 0) { throw 'Selene failed' }
    & git diff --check
    if ($LASTEXITCODE -ne 0) { throw 'Git whitespace check failed' }
    $project = Get-Content -Raw default.project.json | ConvertFrom-Json
    if ($project.servePort -ne 34879 -or $project.tree.PSObject.Properties.Name -contains 'Workspace') { throw 'Unexpected project mapping/port' }
    $forbidden = Get-ChildItem src -Recurse -Filter '*.luau' | Select-String -Pattern 'DataStoreService|ProfileStore|MarketplaceService|HttpService|InsertService|loadstring'
    if ($forbidden) { throw 'Out-of-scope service or runtime loading in source' }
    New-Item -ItemType Directory -Force build | Out-Null
    & ./.tools/rojo/rojo.exe build default.project.json -o build/JunkyardLaunch.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Rojo build failed' }
    Write-Output 'PASS: formatting, lint, whitespace, scope, project configuration, and static build. Studio gameplay is separate.'
} finally { Pop-Location }
