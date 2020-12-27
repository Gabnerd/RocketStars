@echo off

for %%I in (.) do set nomeProjeto=%%~nxI

echo compilando...

.\tools\rgbds\rgbasm -o obj/main.o main.asm
.\tools\rgbds\rgblink -o dist/%nomeProjeto%.gb obj/main.o
.\tools\rgbds\rgbfix -v -p 0 dist/%nomeProjeto%.gb
