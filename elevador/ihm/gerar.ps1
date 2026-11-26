# Gera os STLs e as imagens de previa a partir de ihm.scad.
# Requer OpenSCAD (winget install OpenSCAD.OpenSCAD).
param([string]$OpenScad = "C:\Program Files\OpenSCAD\openscad.com")

$ErrorActionPreference = "Stop"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scad = Join-Path $dir "ihm.scad"
New-Item -ItemType Directory -Force (Join-Path $dir "stl"), (Join-Path $dir "img") | Out-Null

foreach ($p in "caixa", "tampa", "anel_parada", "calco") {
    Write-Host "STL: $p"
    & $OpenScad -o (Join-Path $dir "stl\$p.stl") -D ('part=\"{0}\"' -f $p) $scad
    if ($LASTEXITCODE -ne 0) { throw "Falha ao gerar $p" }
    & $OpenScad -o (Join-Path $dir "img\$p.png") -D ('part=\"{0}\"' -f $p) --imgsize=900,700 --viewall --autocenter --colorscheme=Tomorrow $scad
}

Write-Host "Imagem: montagem"
& $OpenScad -o (Join-Path $dir "img\montagem.png") -D 'part=\"montagem\"' --imgsize=1200,800 --camera=0,0,25,55,0,20,520 --colorscheme=Tomorrow $scad
& $OpenScad -o (Join-Path $dir "img\montagem_inclinada.png") -D 'part=\"montagem_inclinada\"' --imgsize=1200,800 --camera=0,0,40,70,0,60,560 --colorscheme=Tomorrow $scad
