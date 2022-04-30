include "include/hardware.inc"

; Constants
STACK_SIZE EQU $7A
;; Stack starts at $FFFE

; $0000 - $003F: RST handlers.

SECTION "restarts", ROM0[$0000]
ret
REPT 7
    nop
ENDR
; $0008
ret
REPT 7
    nop
ENDR
; $0010
ret
REPT 7
    nop
ENDR
; $0018
ret
REPT 7
    nop
ENDR
; $0020
ret
REPT 7
    nop
ENDR
; $0028
ret
REPT 7
    nop
ENDR
; $0030
ret
REPT 7
    nop
ENDR
; $0038
ret
REPT 7
    nop
ENDR

; Interrupt addresses
SECTION "Vblank interrupt", ROM0[$0040]
    reti

SECTION "LCD controller status interrupt", ROM0[$0048]
    reti

SECTION "Timer overflow interrupt", ROM0[$0050]
    reti

SECTION "Serial transfer completion interrupt", ROM0[$0058]
    reti

SECTION "P10-P13 signal low edge interrupt", ROM0[$0060]
    reti

; Reserved stack space
SECTION "Stack", HRAM[$FFFE - STACK_SIZE]
    ds STACK_SIZE

; Control starts here, but there's more ROM header several bytes later, so the
; only thing we can really do is immediately jump to after the header

SECTION "Header", ROM0[$0100]
    nop
    jp $0150

    NINTENDO_LOGO

; $0134 - $013E: The title, in upper-case letters, followed by zeroes.
DB "HUGE"
DS 7 ; padding
; $013F - $0142: The manufacturer code. Empty for now
DS 4
DS 1
; $0144 - $0145: "New" Licensee Code, a two character name.
DB "NF"

SECTION "cooked00", ROMX, BANK[1]
the_vgm:
incbin "cooked00"
SECTION "cooked01", ROMX, BANK[2]
incbin "cooked01"
SECTION "cooked02", ROMX, BANK[3]
incbin "cooked02"
SECTION "cooked03", ROMX, BANK[4]
incbin "cooked03"
SECTION "cooked04", ROMX, BANK[5]
incbin "cooked04"
SECTION "cooked05", ROMX, BANK[6]
incbin "cooked05"
SECTION "cooked06", ROMX, BANK[7]
incbin "cooked06"
SECTION "cooked07", ROMX, BANK[8]
incbin "cooked07"
SECTION "cooked08", ROMX, BANK[9]
incbin "cooked08"
SECTION "cooked09", ROMX, BANK[10]
incbin "cooked09"
SECTION "cooked10", ROMX, BANK[11]
incbin "cooked10"
SECTION "cooked11", ROMX, BANK[12]
incbin "cooked11"

; Initialization
SECTION "main", ROM0[$0150]
    jp _init

_paint_tile:
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ret

_init:
    ld a, 0
    ld [rIF], a
    inc a
    ld [rIE], a
    halt
    nop

    ; Set LCD palette for grayscale mode; yes, it has a palette
    ld a, %11100100
    ld [$FF00+$47], a

    ;; Fill with pattern
    ld hl, $8000
    ld bc, `10000000
    call _paint_tile
    ld bc, `01000000
    call _paint_tile
    ld bc, `00100000
    call _paint_tile
    ld bc, `00010000
    call _paint_tile
    ld bc, `00001000
    call _paint_tile
    ld bc, `00000100
    call _paint_tile
    ld bc, `00000010
    call _paint_tile
    ld bc, `00000001
    call _paint_tile

    ; Enable sound globally
    ld a, $80
    ld [rAUDENA], a
    ; Enable all channels in stereo
    ld a, $FF
    ld [rAUDTERM], a
    ; Set volume
    ld a, $77
    ld [rAUDVOL], a

    ld a, IEF_VBLANK
    ld [rIE], a

    ei

    ;; bank
    ld c, 1

    ld hl, the_vgm + $C0
    ld b, 1
_halt:
    halt
    nop

    dec b
    jr nz, _halt

.step:
    ld a, [hl+]
    cp $FF
    jr z, .bankswitch
    cp $5F
    jr z, .port1
    cp $5E
    jr z, .port0
    cp $61
    jr z, .wait

    ;; couldnt find command
    jr .step

.bankswitch:
    inc c
    ld a, c
    ld [rROMB0], a
    ld hl, the_vgm
    jr .step
.port1:
    ld a, [hl+]
    ld [$2003], a
    ld a, [hl+]
    ld [$2004], a
    jr .step
.port0:
    ld a, [hl+]
    ld [$2001], a
    ld a, [hl+]
    ld [$2002], a
    jr .step
.wait:
    ld a, [hl+]
    ld b, a
    ; inc b
    inc hl
.done:
    jr _halt