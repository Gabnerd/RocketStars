INCLUDE "gbhw.inc"

;definir local na memoria de objetos para as propriedas dos sprites
_SPR0_Y EQU _OAMRAM
_SPR0_X EQU _OAMRAM+1
_SPR0_NUM EQU _OAMRAM+2
_SPR0_ATT EQU _OAMRAM+3

_SPR1_Y EQU _OAMRAM+4
_SPR1_X EQU _OAMRAM+5
_SPR1_NUM EQU _OAMRAM+6
_SPR1_ATT EQU _OAMRAM+7

;definir local da memoria de de acesso aleatorio para dados comuns
_PAD EQU _RAM
_GRAV EQU _RAM+1
_GROUND EQU _RAM+2
_SPR_ROCKET_SUM EQU _RAM+3

SECTION "start", ROM0[$0100]
    nop
    jp inicio

    ;definir cabeçalho do rom
    ROM_HEADER ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

;label para inicio
inicio:
    nop
    di
    ld sp, $ffff

;inicialização de valores nos locais especificos da memoria
inicializacao:

    ld hl, _SPR_ROCKET_SUM
    ld [hl], 0

    ;definindo primeira palheta(da cor mais escura 11 até a mais clara 00)
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

    ;definindo sengunda palheta
    ld a, %11010000
    ld [rOBP1], a

    ;zerando o X e Y do scroll da tela
    ld a, 0
    ld [rSCX], a
    ld [rSCY], a

    call apagaLCD

    ;copiando tiles para a memoria de video
    ld hl, Tiles
    ld de, _VRAM
    ld bc, FimTiles-Tiles
    call CopiarMemoria

    ;copiando mapa de tiles do fundo na tela 0
    ld hl, FundoEspaco
    ld de, _SCRN0
    ld bc, 32*32
    call CopiarMemoria

    ;zerando a memoria de objetos
    ld de, _OAMRAM
	ld bc, 40*4
	ld l, 0
	call PreencherMemoria

    ;definindo a gravidade para 2 pixels por frame
    ld a, 2
    ld [_GRAV], a

    ;definindo onde começa o chão
    ld a, 152-16
    ld [_GROUND], a

    ;definindo as propriedades dos 2 sprites
    ld a, 100
	ld [_SPR0_Y], a
	ld a, 100
	ld [_SPR0_X], a
	ld a, 1
	ld [_SPR0_NUM], a
	ld a, 0
	ld [_SPR0_ATT], a

    ld a, 100+8
	ld [_SPR1_Y], a
	ld a, 100
	ld [_SPR1_X], a
	ld a, 2
	ld [_SPR1_NUM], a
	ld a, 0
	ld [_SPR1_ATT], a

    ;configurando a tela LCD
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
    ld [rLCDC], a

movimiento:
    call lerInput
.wait
	ld a, [rLY]
	cp 145
	jr nz, .wait

    ld a, [_PAD]
    and %00010000
    call nz, andarDireita

    ld a, [_PAD]
    and %00100000
    call nz, andarEsquerda

    ld a, [_PAD]
    and %00000001
    call nz, voar

    ld a, [_PAD]
	and %11111111
	call z, vooDesligado


    ld a, [_SPR1_Y]
    ld hl, _GROUND
    cp [hl]
    call c, gravidade

	ld bc, 2000
	call retardo
    
	jr movimiento

voar:
    ld a, 3
    ld [_SPR1_NUM], a
    ld a, [_SPR0_Y]
    ld b, 4
    sub a, b
    ld [_SPR0_Y], a
    ld a, [_SPR1_Y]
    sub a, b
    ld [_SPR1_Y], a
    ret

vooDesligado:
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    cp [hl]
    ret c
    ld a, 2
    ld [_SPR1_NUM], a
    ret

andarDireita:
    ld a, [_SPR0_X]
    inc a
    ld [_SPR0_X], a
    ld a, [_SPR1_X]
    inc a
    ld [_SPR1_X], a
    ld a, [_SPR0_ATT]
	res 5, a
	ld [_SPR0_ATT], a
    ld [_SPR1_ATT], a
    call caminhaRocket
    ret

andarEsquerda:
    ld a, [_SPR0_X]
    dec a
    ld [_SPR0_X], a
    ld a, [_SPR1_X]
    dec a
    ld [_SPR1_X], a
    ld a, [_SPR0_ATT]
	set 5, a
	ld [_SPR0_ATT], a
    ld [_SPR1_ATT], a
    call caminhaRocket
    ret

caminhaRocket:
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    cp [hl]
    ret c
    ld a, [_SPR1_NUM]
    cp 11
    jp z, vooDesligado

    ld hl, _SPR1_NUM
    ld [hl], 11

    ret

lerInput:
    ld a, %00100000
    ld [rP1], a

    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]

    and $0F
    swap a
    ld b, a

    ld a, %00010000
    ld [rP1], a

    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]

    and $0F
    or b

    cpl
    ld [_PAD], a

    ret

apagaLCD:
    ld a, [rLCDC]
    rlca
    ret nc

.esperarVBlank
    ld a, [rLY]
    cp 145
    jr nz, .esperarVBlank

    ld a, [rLCDC]
    res 7,a 
    ld [rLCDC], a

    ret

CopiarMemoria:
    ld a, [hl]
    ld [de], a
    dec bc

    ld a, c
    or b
    ret z

    inc hl
    inc de
    jr CopiarMemoria

PreencherMemoria:
    ld a, l
    ld [de], a
    dec bc

    ld a, c
    or b
    ret z

    inc de
    jr PreencherMemoria

retardo:
.delay:
	dec bc
	ld a, b
	or c
	jr z, .fin_delay
	nop
	jr .delay
.fin_delay:
	ret

CopiaMemoria:
	ld a, [hl]
	ld [de], a
	dec bc

	ld a, c
	or b
	ret z

	inc hl
	inc de
	jr CopiaMemoria

RellenaMemoria:
	ld a, l
	ld [de], a
	dec bc

	ld a, c
	or b
	ret z
	inc de
	jr RellenaMemoria

gravidade:
    ld a, [_SPR0_Y]
    ld hl, _GRAV
    add a, [hl]
    ld [_SPR0_Y], a
    ld a, [_SPR1_Y]
    add a, [hl]
    ld [_SPR1_Y], a
    ret




Tiles:
    include "Foguete_Tiles.z80"
FimTiles:

FundoEspaco:
    include "FundoEspaco.z80"
FimFundoEspaco: