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

_ROCKET_SPR0_Y EQU _OAMRAM+8
_ROCKET_SPR0_X EQU _OAMRAM+9
_ROCKET_SPR0_NUM EQU _OAMRAM+10
_ROCKET_SPR0_ATT EQU _OAMRAM+11

_ROCKET_SPR1_Y EQU _OAMRAM+12
_ROCKET_SPR1_X EQU _OAMRAM+13
_ROCKET_SPR1_NUM EQU _OAMRAM+14
_ROCKET_SPR1_ATT EQU _OAMRAM+15

_ROCKET_SPR2_Y EQU _OAMRAM+16
_ROCKET_SPR2_X EQU _OAMRAM+17
_ROCKET_SPR2_NUM EQU _OAMRAM+18
_ROCKET_SPR2_ATT EQU _OAMRAM+19

_ROCKET_SPR3_Y EQU _OAMRAM+20
_ROCKET_SPR3_X EQU _OAMRAM+21
_ROCKET_SPR3_NUM EQU _OAMRAM+22
_ROCKET_SPR3_ATT EQU _OAMRAM+23

_ROCKET_SPR4_Y EQU _OAMRAM+24
_ROCKET_SPR4_X EQU _OAMRAM+25
_ROCKET_SPR4_NUM EQU _OAMRAM+26
_ROCKET_SPR4_ATT EQU _OAMRAM+27

_BASE_SPR0_Y EQU _OAMRAM+28
_BASE_SPR0_X EQU _OAMRAM+29
_BASE_SPR0_NUM EQU _OAMRAM+30
_BASE_SPR0_ATT EQU _OAMRAM+31

_BASE_SPR1_Y EQU _OAMRAM+32
_BASE_SPR1_X EQU _OAMRAM+33
_BASE_SPR1_NUM EQU _OAMRAM+34
_BASE_SPR1_ATT EQU _OAMRAM+35

_BASE_SPR2_Y EQU _OAMRAM+36
_BASE_SPR2_X EQU _OAMRAM+37
_BASE_SPR2_NUM EQU _OAMRAM+38
_BASE_SPR2_ATT EQU _OAMRAM+39

_BASE_SPR3_Y EQU _OAMRAM+40
_BASE_SPR3_X EQU _OAMRAM+41
_BASE_SPR3_NUM EQU _OAMRAM+42
_BASE_SPR3_ATT EQU _OAMRAM+43

_BASE_SPR4_Y EQU _OAMRAM+44
_BASE_SPR4_X EQU _OAMRAM+45
_BASE_SPR4_NUM EQU _OAMRAM+46
_BASE_SPR4_ATT EQU _OAMRAM+47

;partes derrubadas do foguete
_PART_SPR0_Y EQU _OAMRAM+48
_PART_SPR0_X EQU _OAMRAM+49
_PART_SPR0_NUM EQU _OAMRAM+50
_PART_SPR0_ATT EQU _OAMRAM+51

_PART_SPR1_Y EQU _OAMRAM+52
_PART_SPR1_X EQU _OAMRAM+53
_PART_SPR1_NUM EQU _OAMRAM+54
_PART_SPR1_ATT EQU _OAMRAM+55

_PART_SPR2_Y EQU _OAMRAM+56
_PART_SPR2_X EQU _OAMRAM+57
_PART_SPR2_NUM EQU _OAMRAM+58
_PART_SPR2_ATT EQU _OAMRAM+59

_PART_SPR3_Y EQU _OAMRAM+60
_PART_SPR3_X EQU _OAMRAM+61
_PART_SPR3_NUM EQU _OAMRAM+62
_PART_SPR3_ATT EQU _OAMRAM+63

_PART_SPR4_Y EQU _OAMRAM+64
_PART_SPR4_X EQU _OAMRAM+65
_PART_SPR4_NUM EQU _OAMRAM+66
_PART_SPR4_ATT EQU _OAMRAM+67

;definir local da memoria de de acesso aleatorio para dados comuns
_PAD EQU _RAM
_GRAV EQU _RAM+1
_GROUND EQU _RAM+2
_AUX0 EQU _RAM+3
_LOCAL_ROCKET EQU _RAM+4
_STATUS_ROCKET_BUILD EQU _RAM+5
_CARREGADO EQU _RAM+6

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

    ;atribuindo valor para a localização central do foguete
    ld a, 40
    ld [_LOCAL_ROCKET], a

    ld a, 0
    ld [_CARREGADO], a

    ;esquema do numero do sprite do foguete
    ;  4
    ;  3
    ;1 0 2
    ;
    ; bit função
    ;  1  mostrar sprite 0
    ;  2  mostrar sprite 1
    ;  3  mostrar sprite 2
    ;  4  mostrar sprite 3
    ;  5  mostrar sprite 4
    ;bit 6, 7 e 8 são inutilizados(por enquanto)
    ld a, %00000000
    ld [_STATUS_ROCKET_BUILD], a

    ;definindo as propriedades dos 2 sprites que compoem o personagem
    ld a, 100
	ld [_SPR0_Y], a
	ld a, $9E
	ld [_SPR0_X], a
	ld a, 1
	ld [_SPR0_NUM], a
    ld a, 0
	ld [_SPR0_ATT], a

    ld a, 100+8
	ld [_SPR1_Y], a
	ld a, $9E
	ld [_SPR1_X], a
	ld a, 2
	ld [_SPR1_NUM], a
    ld a, 0
	ld [_SPR1_ATT], a

    ;posição dos sprites de cada parte do foguete
    ;  4
    ;  3
    ;1 0 2
    ;apoio central do foguete
    ;o centro é usando como base para todos os calculos dos outros sprites do foguete
    ld a, [_GROUND]
    sub 3
    ld [_ROCKET_SPR0_Y], a
    ld a, [_LOCAL_ROCKET]
    ld [_ROCKET_SPR0_X], a
    ld a, 0
    ld [_ROCKET_SPR0_NUM], a
    ld a, 0
    ld [_ROCKET_SPR0_ATT], a

    ;asa esquerda
    ld a, [_ROCKET_SPR0_Y]
    ld [_ROCKET_SPR1_Y], a
    ld a, [_ROCKET_SPR0_X]
    sub 8
    ld [_ROCKET_SPR1_X], a
    ld a, 0
    ld [_ROCKET_SPR1_NUM], a
    ld a, 0
    set 5, a
    ld [_ROCKET_SPR1_ATT], a

    ;asa direita
    ld a, [_ROCKET_SPR0_Y]
    ld [_ROCKET_SPR2_Y], a
    ld a, [_ROCKET_SPR0_X]
    add 8
    ld [_ROCKET_SPR2_X], a
    ld a, 0
    ld [_ROCKET_SPR2_NUM], a
    ld a, 0
    ld [_ROCKET_SPR2_ATT], a

    ;corpo superior
    ld a, [_ROCKET_SPR0_Y]
    sub 8
    ld [_ROCKET_SPR3_Y], a
    ld a, [_ROCKET_SPR0_X]
    ld [_ROCKET_SPR3_X], a
    ld a, 0
    ld [_ROCKET_SPR3_NUM], a
    ld a, 0
    ld [_ROCKET_SPR3_ATT], a

    ;bico superior
    ld a, [_ROCKET_SPR3_Y]
    sub 8
    ld [_ROCKET_SPR4_Y], a
    ld a, [_ROCKET_SPR3_X]
    ld [_ROCKET_SPR4_X], a
    ld a, 0
    ld [_ROCKET_SPR4_NUM], a
    ld a, 0
    ld [_ROCKET_SPR4_ATT], a










    ;zona de testes para colocação das partes espalhadas do foguete
    ld a, [_GROUND]
    ld [_PART_SPR0_Y], a
    ld a, 56+16
    ld [_PART_SPR0_X], a
    ld a, 18
    ld [_PART_SPR0_NUM], a
    ld a, 0
    ld [_PART_SPR0_ATT], a

    ld a, [_GROUND]
    ld [_PART_SPR1_Y], a
    ld a, [_PART_SPR0_X]
    add 16
    ld [_PART_SPR1_X], a
    ld a, 17
    ld [_PART_SPR1_NUM], a
    ld a, 0
    set 5, a
    ld [_PART_SPR1_ATT], a

    ld a, [_GROUND]
    ld [_PART_SPR2_Y], a
    ld a, [_PART_SPR1_X]
    add 16
    ld [_PART_SPR2_X], a
    ld a, 17
    ld [_PART_SPR2_NUM], a
    ld a, 0
    ld [_PART_SPR2_ATT], a

    ld a, [_GROUND]
    ld [_PART_SPR3_Y], a
    ld a, [_PART_SPR2_X]
    add 16
    ld [_PART_SPR3_X], a
    ld a, 22
    ld [_PART_SPR3_NUM], a
    ld a, 0
    ld [_PART_SPR3_ATT], a

    ld a, [_GROUND]
    ld [_PART_SPR4_Y], a
    ld a, [_PART_SPR3_X]
    add 16
    ld [_PART_SPR4_X], a
    ld a, 19
    ld [_PART_SPR4_NUM], a
    ld a, 0
    ld [_PART_SPR4_ATT], a







    ;configurando a tela LCD
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
    ld [rLCDC], a

movimento:
    call lerInput
    call entregarPeca
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
    call controleCarregamento
    call conferirStatusFoguete
	ld bc, 2000
	call retardo
	jr movimento

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
    ld a, 12
    ld [_SPR1_NUM], a
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

conferirStatusFoguete:
    ;esquema do numero do sprite do foguete
    ;  4
    ;  3
    ;1 0 2
    ;
    ; bit função
    ;  1  mostrar sprite 0
    ;  2  mostrar sprite 1
    ;  3  mostrar sprite 2
    ;  4  mostrar sprite 3
    ;  5  mostrar sprite 4
    ;bit 6, 7 e 8 são inutilizados(por enquanto)
    ;
    ;SPR0_NUM = 18
    ;SPR1_NUM = 17
    ;SPR2_NUM = 17
    ;SPR3_NUM = 22
    ;SPR4_NUM = 19
    
    call .conferirBico
    call .conferirCorpo
    call .conferirCentro
    call .conferirAsaEsquerda
    call .conferirAsaDireita
    ret
.conferirBico:
    ld a, [_STATUS_ROCKET_BUILD]
    and %00001000
    ret z
    ld hl, _ROCKET_SPR4_NUM
    ld a, 19
    ld [hl], a
    call esconderPeca4
    ret
.conferirCorpo:
    ld a, [_STATUS_ROCKET_BUILD]
    and a, %00010000
    ret z
    ld hl, _ROCKET_SPR3_NUM
    ld [hl], 22
    call esconderPeca3
    ret
.conferirCentro:
    ld a, [_STATUS_ROCKET_BUILD]
    and %10000000
    ret z
    ld hl, _ROCKET_SPR0_NUM
    ld [hl], 18
    call esconderPeca0
    ret
.conferirAsaEsquerda:
    ld a, [_STATUS_ROCKET_BUILD]
    and %01000000
    ret z
    ld hl, _ROCKET_SPR1_NUM
    ld [hl], 17
    call esconderPeca1
    ret
.conferirAsaDireita:
    ld a, [_STATUS_ROCKET_BUILD]
    and %00100000
    ret z
    ld hl, _ROCKET_SPR2_NUM
    ld [hl], 17
    call esconderPeca2
    ret

controleCarregamento:

    ld a, [_CARREGADO]
    cp %10000000
    call z, .setSpr0Carry

    ld a, [_CARREGADO]
    cp %01000000
    call z, .setSpr1Carry

    ld a, [_CARREGADO]
    cp %00100000
    call z, .setSpr2Carry

    ld a, [_CARREGADO]
    cp %00010000
    call z, .setSpr3Carry

    ld a, [_CARREGADO]
    cp %00001000
    call z, .setSpr4Carry

    ld a, [_CARREGADO]
    cp 0
    ret nz
    call .controleCarrySpr0
    call .controleCarrySpr1
    call .controleCarrySpr2
    call .controleCarrySpr3
    call .controleCarrySpr4
    
    ret
.controleCarrySpr0:
    ld a, [_SPR1_X]
    ld hl, _PART_SPR0_X
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    ret nz
    ld a, %10000000
    ld [_CARREGADO], a
    ret
.controleCarrySpr1:
    ld a, [_SPR1_X]
    ld hl, _PART_SPR1_X
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    ret nz
    ld a, %01000000
    ld [_CARREGADO], a
    ret
.controleCarrySpr2:
    ld a, [_SPR1_X]
    ld hl, _PART_SPR2_X
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    ret nz
    ld a, %00100000
    ld [_CARREGADO], a
    ret
.controleCarrySpr3:
    ld a, [_SPR1_X]
    ld hl, _PART_SPR3_X
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    ret nz
    ld a, %00010000
    ld [_CARREGADO], a
    ret
.controleCarrySpr4:
    ld a, [_SPR1_X]
    ld hl, _PART_SPR4_X
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    ret nz
    ld a, %00001000
    ld [_CARREGADO], a
    ret
.setSpr0Carry:
    ld hl, _PART_SPR0_Y
    ld a, [_SPR0_Y]
    sub 8
    ld [hl], a
    ld hl, _PART_SPR0_X
    ld a, [_SPR0_X]
    ld [hl], a
    ret
.setSpr1Carry:
    ld hl, _PART_SPR1_Y
    ld a, [_SPR0_Y]
    sub 8
    ld [hl], a
    ld hl, _PART_SPR1_X
    ld a, [_SPR0_X]
    ld [hl], a
    ret
.setSpr2Carry:
    ld hl, _PART_SPR2_Y
    ld a, [_SPR0_Y]
    sub 8
    ld [hl], a
    ld hl, _PART_SPR2_X
    ld a, [_SPR0_X]
    ld [hl], a
    ret
.setSpr3Carry:
    ld hl, _PART_SPR3_Y
    ld a, [_SPR0_Y]
    sub 8
    ld [hl], a
    ld hl, _PART_SPR3_X
    ld a, [_SPR0_X]
    ld [hl], a
    ret
.setSpr4Carry:
    ld hl, _PART_SPR4_Y
    ld a, [_SPR0_Y]
    sub 8
    ld [hl], a
    ld hl, _PART_SPR4_X
    ld a, [_SPR0_X]
    ld [hl], a
    ret

entregarPeca:
    ld a, [_SPR1_X]
    ld hl, _LOCAL_ROCKET
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    jp nz, entregarPeca2
    ld a, [_STATUS_ROCKET_BUILD]
    ld hl, _CARREGADO
    or [hl]
    ld [_STATUS_ROCKET_BUILD], a
    ld a, %00000000
    ld [_CARREGADO], a
    ret

entregarPeca2:
    ld a, [_SPR1_X]
    ld hl, _LOCAL_ROCKET
    add 1
    sub [hl]
    ld [_AUX0], a
    ld a, [_SPR1_Y]
    ld hl, _GROUND
    sub [hl]
    ld hl, _AUX0
    cp [hl]
    ret nz
    ld a, [_STATUS_ROCKET_BUILD]
    ld hl, _CARREGADO
    or [hl]
    ld [_STATUS_ROCKET_BUILD], a
    ld a, %00000000
    ld [_CARREGADO], a
    ret
esconderPeca0:
    ld a, 0
    ld [_PART_SPR0_NUM], a
    ld [_PART_SPR0_X], a
    ld [_PART_SPR0_Y], a
    ret
esconderPeca1:
    ld a, 0
    ld [_PART_SPR1_X], a
    ld [_PART_SPR1_Y], a
    ld [_PART_SPR1_NUM], a
    ret
esconderPeca2:
    ld a, 0
    ld [_PART_SPR2_NUM], a
    ld [_PART_SPR2_X], a
    ld [_PART_SPR2_Y], a
    ret
esconderPeca3:
    ld a, 0
    ld [_PART_SPR3_NUM], a
    ld [_PART_SPR3_X], a
    ld [_PART_SPR3_Y], a
    ret
esconderPeca4:
    ld a, 0
    ld [_PART_SPR4_NUM], a
    ld [_PART_SPR4_X], a
    ld [_PART_SPR4_Y], a
    ret

Tiles:
    include "Foguete_Tiles.z80"
FimTiles:

FundoEspaco:
    include "FundoEspaco.z80"
FimFundoEspaco: