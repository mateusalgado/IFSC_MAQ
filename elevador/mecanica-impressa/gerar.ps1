# Gera os STLs e as imagens de previa a partir de elevador_impresso.scad.
# Requer OpenSCAD (winget install OpenSCAD.OpenSCAD).
param([string]$OpenScad = "C:\Program Files\OpenSCAD\openscad.com")

$ErrorActionPreference = "Stop"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scad = Join-Path $dir "elevador_impresso.scad"
New-Item -ItemType Directory -Force (Join-Path $dir "stl"), (Join-Path $dir "img") | Out-Null

foreach ($p in "base", "segmento", "emenda", "cabeca", "cabine", "porta", "grampo", "tambor", "gabarito") {
    Write-Host "STL: $p"
    & $OpenScad -o (Join-Path $dir "stl\$p.stl") -D ('part=\"{0}\"' -f $p) $scad
    if ($LASTEXITCODE -ne 0) { throw "Falha ao gerar $p" }
    & $OpenScad -o (Join-Path $dir "img\$p.png") -D ('part=\"{0}\"' -f $p) --imgsize=900,700 --viewall --autocenter --colorscheme=Tomorrow $scad
}

Write-Host "Imagem: montagem"
$m = 'part=\"montagem\"'
& $OpenScad -o (Join-Path $dir "img\montagem.png") -D $m --imgsize=1000,1400 --camera=0,-20,205,68,0,30,1300 --colorscheme=Tomorrow $scad
& $OpenScad -o (Join-Path $dir "img\montagem_fundo.png") -D $m --imgsize=1000,1400 --camera=0,-20,205,68,0,150,1300 --colorscheme=Tomorrow $scad
& $OpenScad -o (Join-Path $dir "img\cabeca_detalhe.png") -D $m --imgsize=1100,800 --camera=0,-30,370,105,0,35,430 --colorscheme=Tomorrow $scad
& $OpenScad -o (Join-Path $dir "img\porta_aberta.png") -D $m --imgsize=1100,800 --camera=5,-60,190,65,0,325,460 --colorscheme=Tomorrow $scad
& $OpenScad -o (Join-Path $dir "img\porta_fechada.png") -D $m -D "porta_aberta=false" --imgsize=1100,800 --camera=5,-60,190,65,0,325,460 --colorscheme=Tomorrow $scad
