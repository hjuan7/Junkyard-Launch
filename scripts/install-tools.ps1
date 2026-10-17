$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$packages = @(
    @('rojo', 'https://github.com/rojo-rbx/rojo/releases/download/v7.7.1/rojo-7.7.1-windows-x86_64.zip', 'D4DFA3493A1613A43FC87312D6DAC660D7C8BF38E6A99AA5DCD0D26154BA0B82', 'E73E956676B8B27FF43F2C5D80E040121E49C2F9E8CC69FD65123799473CF6D3'),
    @('stylua', 'https://github.com/JohnnyMorganz/StyLua/releases/download/v2.6.0/stylua-windows-x86_64.zip', 'FD13B4014E3B779C244BBC03F2C282E357F15BC526DE6A6FA5ECBC447538313C', '8BE0383E979B3C699BF6BFBFC0770038534D071B0479FEE188636C4B54CD338B'),
    @('selene', 'https://github.com/Kampfkarren/selene/releases/download/0.32.0/selene-0.32.0-windows.zip', 'C8B693DE81D0DDC11490D8E1170DD98D775C2B21431144BD8286F738EF416109', 'D5BE79CF17379E243CF3DA7B6D913985261F715585CD37AEEE912474EF6BEC92')
)
$downloads = Join-Path $root '.tools/downloads'
New-Item -ItemType Directory -Force -Path $downloads | Out-Null
foreach ($package in $packages) {
    $archive = Join-Path $downloads ($package[0] + '.zip')
    if (!(Test-Path -LiteralPath $archive)) { Invoke-WebRequest -UseBasicParsing -Uri $package[1] -OutFile $archive }
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $package[2]) { throw "Tool checksum mismatch: $($package[0])" }
    $executable = Join-Path $root ('.tools/' + $package[0] + '/' + $package[0] + '.exe')
    if (Test-Path -LiteralPath $executable) {
        if ((Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash -ne $package[3]) { throw "Installed tool checksum mismatch: $($package[0])" }
        continue
    }
    Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $root ('.tools/' + $package[0])) -Force
}
