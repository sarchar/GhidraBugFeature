
    .segment "zp", 0, 0x100, -1
    .zp

tmp0 = $00
tmp2 = $02

tmp4 = $04
tmp4_other_label = tmp4

buffer = $80
buffer_size = $10

    .segment "rom", 0x8000, 0x8000, 0
    .rom

_nmi:
_irq:
    rti

_reset:
    ; only address 0 gets the => reference
    lda #tmp0
    lda #tmp2

    ; also address 0 gets the => reference,
    lda #00
    sta tmp0,x
    lda #$20
    sta tmp0+1,x

    ; but when indirect, it doesn't happen
    sta (tmp0, x)
    sta (tmp0), y

    ; but alternative labels can't be assigned with dynamically computed offset values
    sta tmp4,x
    lda #$20
    sta tmp4+1,x   ; want to change the associated reference to tmp4, not tmp4+1 as a whole label

    ; 'offset' isn't really used in 6502 assembly
    sta buffer+8

    ; offsets into arrays should show the offset value
    ldy #$05
    ldx #$10
    lda #$ff
clear_memory:
    sta buffer-5, y
    dex
    bne clear_memory

    ; jump tables are often pointers to functions minus 1, so
    ; they can be 'returned' to
    lda #$00            ; multiply index by 2
    asl
    tay
    iny                 ; push the high byte
    lda jump_table, y
    pha
    dey                 ; push the low byte
    lda jump_table, y
    pha
    rts                 ; return to the function

jump_table:
    .dw function1-1
    .dw function2-1

function1:
    jmp function1

function2:
    nop
    nop
    rts


    .org $fffa
NMI:
    .dw _nmi
RESET:
    .dw _reset
IRQ:
    .dw _irq

