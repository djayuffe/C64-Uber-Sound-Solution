; =============================================================================
; FINAL HARDENING: no dot-local labels, message immediate safe, long branches guarded.
; EXTACID: extra peak repeat SLOT10-15, still starts at SLOT4 TECHNOA.
; ARPSIDTECHACID: ARPSID technical scroller text plus acid filter/arp LFO instrument polish.
; A000POLISH: one active sprite shape, more asset margin, stricter guard.
; A000FIX: H_order duplicate repeat removed so asset block stays below $a000.
; FULLAUDITFIX: strict full source audit cleanup, stale files removed, 4-sprite table fixed.
; BERLINFULL: music from uploaded music(5).txt, previous music removed, PRG build enabled.
; EYEANDU: bottom3 sine only, own top line, reactive top sprites.
; UBER SOUND SOLUTION — ARPSID FEATURES SINE SCROLLER + BERLIN MUSIC
; BASIC: 10 SYS4096
; =============================================================================

* = $0801
!byte $0b,$08,$0a,$00,$9e,$34,$30,$39,$36,$00,$00,$00 ; 10 SYS4096

BITMAP_ADDR   = $2000
SCREEN_ADDR   = $0400
COLOR_RAM     = $d800
CHARSET_ADDR  = $0800
ASSET_ADDR    = $6000
SPLIT_LINE    = $c8
SCROLL_DIV    = $04
SPRITE_BASE   = $3f80

zpSrcLo       = $fb
zpSrcHi       = $fc
zpDstLo       = $fd
zpDstHi       = $fe
zpCntLo       = $02
zpCntHi       = $03
zpMsgIdx      = $04
zpPhase       = $05
zpScrollDiv   = $06
MusicSub      = $07
MusicStep     = $08
MusicOrderLo  = $09
MusicOrderHi  = $0a
MusicDrum     = $0b
MusicLead     = $0c
SongFlags     = $0d
StarFrame     = $0e
BeatFlash     = $0f
zpChar        = $10
zpRow         = $11
zpCol         = $12
EffectPhase   = $13

* = $1000
Start:
        sei
        ldx #$ff
        txs
        lda #$2f
        sta $00
        lda #$35
        sta $01

        lda #$7f
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d

        lda $dd02
        ora #%00000011
        sta $dd02

        lda $dd00
        and #%11111100
        ora #%00000011
        sta $dd00

        lda #$00
        sta $d015
        sta $d020
        sta $d021
        lda #$0b              ; display off while copying assets
        sta $d011

        jsr InstallAssets
        jsr InstallStarSprites
        jsr SID_Init
        jsr Scroller_Clear

        lda #0
        sta zpMsgIdx
        sta zpPhase
        sta zpScrollDiv
        sta MusicSub
        sta MusicStep
        sta MusicDrum
        sta MusicLead
        sta SongFlags
        sta StarFrame
        sta BeatFlash
        sta EffectPhase
        lda #<H_order
        sta MusicOrderLo
        lda #>H_order
        sta MusicOrderHi

        lda #<IrqTop
        sta $fffe
        lda #>IrqTop
        sta $ffff
        lda #<NmiStub
        sta $fffa
        lda #>NmiStub
        sta $fffb

        lda #$01
        sta $d019
        sta $d01a
        lda #$00
        sta $d012
        lda $d011
        and #$7f
        sta $d011
        cli
Main:
        jmp Main

InstallAssets:
        lda #<uber_bitmap_src
        sta zpSrcLo
        lda #>uber_bitmap_src
        sta zpSrcHi
        lda #<BITMAP_ADDR
        sta zpDstLo
        lda #>BITMAP_ADDR
        sta zpDstHi
        lda #<8000
        sta zpCntLo
        lda #>8000
        sta zpCntHi
        jsr CopyCount

        lda #<uber_screen_src
        sta zpSrcLo
        lda #>uber_screen_src
        sta zpSrcHi
        lda #<SCREEN_ADDR
        sta zpDstLo
        lda #>SCREEN_ADDR
        sta zpDstHi
        lda #<1000
        sta zpCntLo
        lda #>1000
        sta zpCntHi
        jsr CopyCount

        lda #<uber_color_src
        sta zpSrcLo
        lda #>uber_color_src
        sta zpSrcHi
        lda #<COLOR_RAM
        sta zpDstLo
        lda #>COLOR_RAM
        sta zpDstHi
        lda #<1000
        sta zpCntLo
        lda #>1000
        sta zpCntHi
        jsr CopyCount

        lda #<uber_charset_src
        sta zpSrcLo
        lda #>uber_charset_src
        sta zpSrcHi
        lda #<CHARSET_ADDR
        sta zpDstLo
        lda #>CHARSET_ADDR
        sta zpDstHi
        lda #<2048
        sta zpCntLo
        lda #>2048
        sta zpCntHi
        jsr CopyCount
        rts

CopyCount:
CopyCount_Copy:
        lda zpCntLo
        ora zpCntHi
        beq CopyCount_Done
        ldy #0
        lda (zpSrcLo),y
        sta (zpDstLo),y
        inc zpSrcLo
        bne CopyCount_SrcOk
        inc zpSrcHi
CopyCount_SrcOk:
        inc zpDstLo
        bne CopyCount_DstOk
        inc zpDstHi
CopyCount_DstOk:
        lda zpCntLo
        bne CopyCount_DecLo
        dec zpCntHi
CopyCount_DecLo:
        dec zpCntLo
        jmp CopyCount_Copy
CopyCount_Done:
        rts

InstallStarSprites:
        lda #<StarSpriteData
        sta zpSrcLo
        lda #>StarSpriteData
        sta zpSrcHi
        lda #<SPRITE_BASE
        sta zpDstLo
        lda #>SPRITE_BASE
        sta zpDstHi
        lda #<64               ; A000 polish: copy only one active sprite shape
        sta zpCntLo
        lda #>64
        sta zpCntHi
        jsr CopyCount
        lda #$fe
        ldx #0
InstallStarSprites_Ptrs:
        sta $07f8,x
        inx
        cpx #4
        bne InstallStarSprites_Ptrs
        lda #$0f              ; less sprites: enable only top 4
        sta $d015
        lda #$00
        sta $d010
        sta $d017
        sta $d01d
        sta $d01b
        sta $d01c
        ldx #0
InstallStarSprites_InitPos:
        lda StarXInit,x
        sta $d000,x
        lda StarYInit,x
        sta $d001,x
        inx
        inx
        cpx #8
        bne InstallStarSprites_InitPos
        ldx #0
InstallStarSprites_InitCol:
        lda StarColorInit,x
        sta $d027,x
        inx
        cpx #4
        bne InstallStarSprites_InitCol
        rts

StarTick:
        inc StarFrame
        ldx #0
StarTick_Loop:
        lda $d000,x
        clc
        adc StarSpeedByReg,x
        ldy BeatFlash
        beq StarTick_NoBoost
        clc
        adc #$03              ; beat-aware star acceleration / top sprites reactive boost
StarTick_NoBoost:
        cmp #$ea
        bcc StarTick_XOk
        lda StarXReset,x
StarTick_XOk:
        sta $d000,x
        txa
        lsr
        tay
        lda StarFrame
        and #$0f
        clc
        adc StarTwinkleOff,y
        and #$0f
        tay
        lda StarTwinkleColors,y
        txa
        lsr
        tax
        sta $d027,x
        txa
        asl
        tax
        inx
        inx
        cpx #8
        bne StarTick_Loop
        rts

EffectTick:
        inc EffectPhase

        ; SID PWM/rave wobble every frame, layered over the row player.
        lda EffectPhase
        asl
        asl
        and #$7f
        sta $d409
        lda EffectPhase
        lsr
        and #$03
        ora #$08
        sta $d40a

        ; Beat-reactive border + bitmap multicolor flash.
        lda BeatFlash
        bne EffectTick_Active
        jmp EffectTick_Idle          ; long-safe: active block is too large for BEQ
EffectTick_Active:
        tax
        dec BeatFlash
        lda DepthExpandX,x     ; MICROSHIMMER: extra bitmap/sprite shimmer phase, black border and stable text preserved.
; DEPTHPULSE: beat-depth X expansion mask
        sta $d01d
        lda DepthExpandY,x     ; DEPTHPULSE: beat-depth Y expansion mask
        sta $d017
        lda #$00              ; black border preserved, never flash $d020
        sta $d020
        lda BeatColors,x      ; bitmap/sprite color pulse only
        sta $d022
        sta $d027
        eor #$07              ; sprite shimmer contrast
        sta $d028
        eor #$0f
        sta $d029
        lda BeatMC2,x
        sta $d023
        sta $d02a
        lda EffectPhase        ; MICROSHIMMER: extra bitmap color phase
        and #$0f
        tay
        lda MicroShimmer,y
        sta $d022              ; bitmap shimmer, border untouched
        eor BeatMC2,x
        and #$0f
        sta $d02a              ; sprite shimmer tail

        lda SpriteBeatY0,x     ; vertical beat bounce, 4 sprites only
        sta $d001
        lda SpriteBeatY1,x
        sta $d003
        lda SpriteBeatY2,x
        sta $d005
        lda SpriteBeatY3,x
        sta $d007

        lda SpriteBeatX0,x     ; horizontal beat wobble
        sta $d000
        lda SpriteBeatX1,x
        sta $d002
        lda SpriteBeatX2,x
        sta $d004
        lda SpriteBeatX3,x
        sta $d006
        rts
EffectTick_Idle:
        lda #$00              ; BLACKBORDERFINAL: idle border lock
        sta $d020
        lda #$00              ; collapse top sprites when beat decays
        sta $d01d
        sta $d017
        lda #$30              ; restore stable top sprite Y positions, 4 sprites only
        sta $d001
        lda #$38
        sta $d003
        lda #$48
        sta $d005
        lda #$58
        sta $d007
        lda #$20              ; EYECANDYPLUS: restore stable sprite X positions
        sta $d000
        lda #$68
        sta $d002
        lda #$a0
        sta $d004
        lda #$c8
        sta $d006
        lda SongFlags
        and #$02
        bne EffectTick_BorderIdle
        lda EffectPhase
        and #$1f
        ora #$20
        sta $d416              ; idle filter shimmer
EffectTick_BorderIdle:
        lda #$00              ; TEXTSTABLEFINAL: true black border, no idle palette write
        sta $d020
        lda EffectPhase        ; MICROSHIMMER: subtle idle bitmap shimmer only
        and #$0f
        tay
        lda MicroShimmer,y
        sta $d022
        rts

SID_Init:
        ldx #$18
        lda #0
SID_Init_Clear:
        sta $d400,x
        dex
        bpl SID_Init_Clear
        lda #$03              ; improved bass: punchier attack/decay
        sta $d405
        lda #$a6              ; improved bass: stronger sustain, short release
        sta $d406
        lda #$01              ; improved arp: clicky acid attack
        sta $d40c
        lda #$66              ; improved arp: controlled release
        sta $d40d
        lda #$05              ; improved drums: tighter transient
        sta $d413
        lda #$04              ; improved drums: short decay/release
        sta $d414
        lda #$00
        sta $d415
        lda #$44              ; improved filter initial cutoff
        sta $d416
        lda #$f7              ; res15 route V1+V2+V3 for punch
        sta $d417
        lda #$3f              ; LP+BP vol15
        sta $d418
        lda #0
        sta MusicSub
        sta MusicStep
        sta MusicDrum
        sta MusicLead
        sta SongFlags
        sta BeatFlash
        sta EffectPhase
        lda #<H_order
        sta MusicOrderLo
        lda #>H_order
        sta MusicOrderHi
        rts

MusicTick:
        inc MusicSub
        lda MusicSub
        cmp #$05
        bcs H_MusicDo
        rts
H_MusicDo:
        lda #0
        sta MusicSub
        ldy #0
        lda (MusicOrderLo),y
        cmp #$ff
        bne H_OrderReady
        lda #<H_order
        sta MusicOrderLo
        lda #>H_order
        sta MusicOrderHi
        ldy #0
        lda (MusicOrderLo),y
H_OrderReady:
        tax
        iny
        lda (MusicOrderLo),y
        sta MusicDrum
        iny
        lda (MusicOrderLo),y
        sta MusicLead
        iny
        lda (MusicOrderLo),y
        sta SongFlags
        lda H_bpat_lo,x
        sta zpSrcLo
        lda H_bpat_hi,x
        sta zpSrcHi
        ldy MusicStep
        lda (zpSrcLo),y
        beq H_NoBass
        tax
        lda H_freqlo,x
        sta $d400
        lda H_freqhi,x
        sta $d401
        lda MusicStep          ; groove polish bass PWM: step+phase acid/sub movement
        asl
        asl
        asl
        clc
        adc EffectPhase
        clc
        adc #$10
        sta $d402
        lda EffectPhase
        lsr
        and #$03
        ora #$08
        sta $d403
        lda #$41              ; pulse bass gate
        bne H_BassDone
H_NoBass:
        lda #$40
        sta $d404
H_BassDone:
        ldx MusicLead
        lda H_lpat_lo,x
        sta zpSrcLo
        lda H_lpat_hi,x
        sta zpSrcHi
        ldy MusicStep
        lda (zpSrcLo),y
        beq H_NoLead
        tax
        lda H_freqlo,x
        sta $d407
        lda H_freqhi,x
        sta $d408
        lda EffectPhase        ; groove polish lead PWM: counter-motion wobble
        asl
        asl
        clc
        adc MusicStep
        and #$7f
        sta $d409
        lda MusicStep
        eor EffectPhase
        lsr
        lsr
        and #$03
        ora #$08
        sta $d40a
        lda #$41              ; acid pulse arp/lead, gate on
        sta $d40b
        bne H_LeadDone
H_NoLead:
        lda #$40
        sta $d40b
H_LeadDone:
        ldx MusicDrum
        lda H_dpat_lo,x
        sta zpSrcLo
        lda H_dpat_hi,x
        sta zpSrcHi
        ldy MusicStep
        lda #$80
        sta $d412
        lda (zpSrcLo),y
        beq H_NoDrum
        cmp #$01
        beq H_Kick
        cmp #$02
        beq H_Hat
        cmp #$05
        beq H_Big
H_Clap:
        lda #$24              ; improved clap/snare: brighter noise pitch
        sta $d40e
        lda #$18
        sta $d40f
        lda #$81
        ldy #$0a
        sty BeatFlash
        bne H_DrumGo
H_Kick:
        lda #$08              ; groove polish kick: lower thump
        sta $d40e
        lda #$02
        sta $d40f
        lda #$24              ; kick filter punch cutoff
        sta $d416
        lda #$41              ; kick uses pulse for harder body
        ldy #$0d
        sty BeatFlash
        bne H_DrumGo
H_Hat:
        lda #$c8              ; groove polish hat: brighter noise tick
        sta $d40e
        lda #$01
        sta $d40f
        lda #$81
        ldy #$06
        sty BeatFlash
        bne H_DrumGo
H_Big:
        lda #$30              ; groove polish big hit
        sta $d40e
        lda #$06
        sta $d40f
        lda #$e0              ; big-hit filter pop
        sta $d416
        lda #$81
        ldy #$0f
        sty BeatFlash
H_DrumGo:
        sta $d412
H_NoDrum:
        lda SongFlags
        and #$02
        beq H_NoBuildFilter
        lda #$f7              ; improved filter: res15 route V1+V2+V3
        sta $d417
        lda #$3f              ; LP+BP vol15
        sta $d418
        lda MusicStep
        asl                   ; stronger step sweep phase
        clc
        adc EffectPhase
        and #$0f
        tay
        lda AcidLfo,y         ; improved acid filter LFO cutoff
        sta $d416
        bne H_FilterDone
H_NoBuildFilter:
        lda #$77              ; fallback still filtered: route V1+V2+V3
        sta $d417
        lda #$3f              ; LP+BP vol15
        sta $d418
        lda EffectPhase
        and #$0f
        tay
        lda AcidLfo,y
        sta $d416
H_FilterDone:
        inc MusicStep
        lda MusicStep
        and #$0f
        sta MusicStep
        bne H_MusicDone
        clc
        lda MusicOrderLo
        adc #$04
        sta MusicOrderLo
        bcc H_MusicDone
        inc MusicOrderHi
H_MusicDone:
        rts

NmiStub:
        rti

IrqTop:
        pha
        txa
        pha
        tya
        pha
        lda #$01
        sta $d019
        lda #$00              ; black border/background discipline
        sta $d020
        sta $d021
        lda #$18
        sta $d016
        lda #$18              ; screen=$0400, bitmap=$2000
        sta $d018
        lda #$3b
        sta $d011
        lda $d012
        and #$0f
        tax
        lda WaveMC1,x
        sta $d022
        lda WaveMC2,x
        sta $d023
        jsr StarTick
        jsr MusicTick
        jsr EffectTick
        lda #<IrqSplit
        sta $fffe
        lda #>IrqSplit
        sta $ffff
        lda #SPLIT_LINE
        sta $d012
        lda $d011
        and #$7f
        sta $d011
        pla
        tay
        pla
        tax
        pla
        rti

IrqSplit:
        pha
        txa
        pha
        tya
        pha
        lda #$01
        sta $d019
        lda #$00              ; BLACKBORDERFINAL: bottom border remains black
        sta $d020
        sta $d021
        lda #$1b
        sta $d011
        lda #$08
        sta $d016
        lda #$12              ; screen=$0400, charset=$0800
        sta $d018
        jsr Scroller_Tick
        lda #<IrqTop
        sta $fffe
        lda #>IrqTop
        sta $ffff
        lda #$00
        sta $d012
        lda $d011
        and #$7f
        sta $d011
        pla
        tay
        pla
        tax
        pla
        rti

Scroller_Tick:
        inc zpScrollDiv
        lda zpScrollDiv
        cmp #SCROLL_DIV
        bcs ScrollerTick_DoScroll
        rts
ScrollerTick_DoScroll:
        lda #0
        sta zpScrollDiv
        inc zpPhase
        lda BeatFlash
        beq ScrollerTick_PhaseOk
        inc zpPhase             ; beat-aware sine lift
ScrollerTick_PhaseOk:
        inc zpMsgIdx
        lda zpMsgIdx
        cmp #MessageEnd-Message
        bcc ScrollerTick_Ok
        lda #0
        sta zpMsgIdx
ScrollerTick_Ok:
        jsr Scroller_DrawSine
        rts

Scroller_Clear:
        lda #0
        sta zpPhase
        sta zpMsgIdx
        jsr Scroller_DrawSine
        rts

Scroller_DrawSine:
        ldx #0
ScrollerDraw_ClearLoop:
        lda #$00
        sta SCREEN_ADDR+40*20,x
        sta SCREEN_ADDR+40*21,x
        sta SCREEN_ADDR+40*22,x
        sta SCREEN_ADDR+40*23,x
        sta SCREEN_ADDR+40*24,x
        lda #$00
        sta COLOR_RAM+40*20,x
        sta COLOR_RAM+40*21,x
        sta COLOR_RAM+40*22,x
        sta COLOR_RAM+40*23,x
        sta COLOR_RAM+40*24,x
        inx
        cpx #40
        bne ScrollerDraw_ClearLoop

        ; own fixed feature line above the sine scroller.
        ldx #0
TopLine_DrawLoop:
        lda TopLineText,x
        sta SCREEN_ADDR+40*20,x
        lda TopLineColor,x           ; TEXTSTABLEFINAL: stable top-line color, no text flash
        sta COLOR_RAM+40*20,x
        inx
        cpx #40
        bne TopLine_DrawLoop

        ; sinus uses only the last three text rows: 22, 23, 24.
        ldx #0
ScrollerDraw_DrawLoop:
        stx zpCol
        txa
        clc
        adc zpMsgIdx
        cmp #MessageEnd-Message
        bcc ScrollerDraw_IdxOk
        sbc #MessageEnd-Message
ScrollerDraw_IdxOk:
        tay
        lda Message,y
        sta zpChar
        lda zpCol
        clc
        adc zpPhase
        and #$1f
        tay
        lda SinRows,y
        sta zpRow
        ldx zpCol
        lda zpRow
        beq ScrollerDraw_Row22
        cmp #1
        beq ScrollerDraw_Row23
ScrollerDraw_Row24:
        lda zpChar
        sta SCREEN_ADDR+40*24,x
        jsr SineColor
        sta COLOR_RAM+40*24,x
        jmp ScrollerDraw_Next
ScrollerDraw_Row22:
        lda zpChar
        sta SCREEN_ADDR+40*22,x
        jsr SineColor
        sta COLOR_RAM+40*22,x
        jmp ScrollerDraw_Next
ScrollerDraw_Row23:
        lda zpChar
        sta SCREEN_ADDR+40*23,x
        jsr SineColor
        sta COLOR_RAM+40*23,x
ScrollerDraw_Next:
        ldx zpCol
        inx
        cpx #40
        beq ScrollerDraw_DrawLoop_done
        jmp ScrollerDraw_DrawLoop ; long-safe bottom3 sine
ScrollerDraw_DrawLoop_done:
        rts

SineColor:
        lda zpCol
        clc
        adc zpPhase
        and #$0f
        tay
        lda ColorWave,y
        rts

WaveMC1:
        !byte $08,$09,$0a,$0f,$01,$07,$0d,$03,$0e,$06,$0e,$03,$0d,$07,$01,$0f ; v4 deeper raster colours
WaveMC2:
        !byte $0b,$0c,$0f,$01,$07,$0a,$08,$02,$09,$0b,$0c,$03,$0d,$05,$0e,$06
ColorWave:
        !byte $01,$07,$0f,$01,$0e,$06,$0a,$08,$02,$09,$0b,$0c,$03,$0d,$05,$0f ; eyeandu text sparkle
SinRows:
        !byte 1,1,2,2,2,1,1,0,0,0,1,1,2,2,1,1,0,0,1,1,2,2,2,1,1,0,0,1,1,2,1,0 ; bottom3 sine only
BeatColors:
        !byte $00,$06,$0e,$03,$0d,$05,$07,$01,$01,$07,$05,$0d,$03,$0e,$06,$00 ; eyeandu beat pulse
BeatMC2:
        !byte $0b,$0c,$0f,$01,$07,$0a,$08,$02,$02,$08,$0a,$07,$01,$0f,$0c,$0b
BorderIdle:
        !byte $00,$00,$06,$00,$0e,$00,$03,$00,$00,$00,$0b,$00,$0c,$00,$0b,$00

ColorSeed:
        !byte $07,$0f,$01,$0e,$08,$0a,$0d,$03,$07,$0f,$01,$0e,$08,$0a,$0d,$03,$07,$0f,$01,$0e,$08,$0a,$0d,$03,$07,$0f,$01,$0e,$08,$0a,$0d,$03,$07,$0f,$01,$0e,$08,$0a,$0d,$03


!if * > BITMAP_ADDR {
        !error "Code grew into bitmap display area at $2000."
}

* = ASSET_ADDR
uber_bitmap_src:
        !bin "assets/uber_bitmap.bin"
uber_screen_src:
        !bin "assets/uber_screen.bin"
uber_color_src:
        !bin "assets/uber_color.bin"
uber_charset_src:
        !bin "assets/uber_custom_font.bin"

TopLineText:
        !byte $00,$0d,$09,$03,$12,$0f,$00,$13,$08,$09,$0d,$0d,$05,$12,$00,$08,$01,$12,$04,$00,$01,$03,$09,$04,$00,$02,$0c,$01,$03,$0b,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
TopLineColor:
        !byte $0f,$07,$01,$07,$0f,$0a,$08,$02,$09,$0b,$0f,$07,$01,$07,$0f,$0a,$08,$02,$09,$0b,$0f,$07,$01,$07,$0f,$0a,$08,$02,$09,$0b,$0f,$07,$01,$07,$0f,$0a,$08,$02,$09,$0b

Message:
        !byte $00,$01,$12,$10,$13,$09,$04,$00,$0d,$09,$03,$12,$0f,$00,$13,$08
        !byte $09,$0d,$0d,$05,$12,$00,$08,$01,$12,$04,$00,$01,$03,$09,$04,$00
MessageEnd:


StarSpriteData:
        !byte $00,$00,$00,$00,$18,$00,$00,$18,$00,$00,$7e,$00,$00,$18,$00,$00
        !byte $18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
StarXInit:        !byte $20,$30,$68,$40,$a0,$50,$c8,$70,$e0,$30,$18,$60,$b8,$48,$d8,$78

; Beat-indexed Y positions for top sprites. 16 entries each.
SpriteBeatY0:
        !byte $30,$2f,$2e,$2d,$2c,$2b,$2c,$2d,$2e,$2f,$30,$2f,$2e,$2d,$2c,$2b
SpriteBeatY1:
        !byte $38,$38,$39,$39,$3a,$3a,$3a,$39,$39,$38,$38,$38,$39,$39,$3a,$3a
SpriteBeatY2:
        !byte $48,$47,$46,$45,$44,$43,$44,$45,$46,$47,$48,$47,$46,$45,$44,$43
SpriteBeatY3:
        !byte $58,$58,$59,$59,$5a,$5a,$5a,$59,$59,$58,$58,$58,$59,$59,$5a,$5a
SpriteBeatX0:
        !byte $20,$1e,$1d,$1c,$1b,$1c,$1d,$1f,$20,$22,$23,$25,$26,$24,$22,$21 ; DEPTHPULSE near-left wobble
SpriteBeatX1:
        !byte $68,$6a,$6b,$6d,$6e,$6c,$6b,$69,$68,$66,$65,$63,$62,$64,$66,$67 ; DEPTHPULSE mid-left wobble
SpriteBeatX2:
        !byte $a0,$9e,$9d,$9b,$9a,$9c,$9d,$9f,$a0,$a2,$a3,$a5,$a6,$a4,$a2,$a1 ; DEPTHPULSE mid-right wobble
SpriteBeatX3:
        !byte $c8,$ca,$cb,$cd,$ce,$cc,$cb,$c9,$c8,$c6,$c5,$c3,$c2,$c4,$c6,$c7 ; DEPTHPULSE near-right wobble
DepthExpandX:
        !byte $0f,$0f,$07,$0f,$03,$07,$0f,$0b,$0f,$0d,$0f,$0e,$0f,$07,$03,$0f ; DEPTHPULSE depth size masks X
DepthExpandY:
        !byte $0f,$07,$0f,$03,$07,$0f,$0b,$0f,$0d,$0f,$0e,$0f,$07,$03,$0f,$0f ; DEPTHPULSE depth size masks Y
MicroShimmer:
        !byte $06,$0e,$03,$0b,$0c,$04,$0f,$07,$01,$07,$0f,$04,$0c,$0b,$03,$0e ; MICROSHIMMER bitmap/sprite shimmer phase
StarYInit:        !byte $30,$38,$48,$58,$3a,$70,$7a,$26,$54,$76,$38,$7c,$44,$62,$78,$7e
StarSpeedByReg:   !byte 1,0,2,0,1,0,3,0,2,0,1,0,2,0,3,0
StarXReset:       !byte $10,0,$08,0,$18,0,$04,0,$0c,0,$14,0,$06,0,$1a,0
StarColorInit:    !byte $01,$07,$0d,$03 ; fullaudit: 4 active sprite colors only
StarTwinkleOff:   !byte 0,2,4,6,8,10,12,14
StarTwinkleColors:
        !byte $01,$0f,$07,$01,$0e,$06,$0a,$08,$02,$09,$0b,$0c,$03,$0d,$05,$0f ; eyeandu star glitter

; -----------------------------------------------------------------------------
; V4 table polish: denser drums, sub-octave bass bounce, brighter lead lift.
; BERLIN song data copied from uploaded c64_asc_berlin.asm
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; BERLIN - A TRIP TO THE GOLDEN HEART HOTEL
; FULL BAR IMPORT from uploaded music(5).txt. Previous music removed.
; ENGINE MAP: V1 bass / V2 acid-lead / V3 drums.
; 15 sections, 4 bars imported per slot = 60 compact 16-step patterns.
; Section cycle: slots 2..15 then 1. Rest $ff from upload -> engine gate-off $00.
; -----------------------------------------------------------------------------
AcidLfo:
        !byte $20,$2c,$3c,$52,$6c,$88,$a6,$c4,$e4,$d0,$b8,$98,$78,$58,$3c,$28 ; groove polish acid filter LFO
H_order:
        !byte $0d,$0d,$0d,$02,$0e,$0e,$0e,$02,$0f,$0f,$0f,$02,$10,$10,$10,$02 ; BLACKBORDERFINAL: keep border black, no beat flash on $d020, preserve groove/filter punch.
; GROOVEPOLISH: kick/big-hit filter punch, tighter PWM interplay, final groove polish.
; INSTRFILTERFIX: improved bass/drum instruments and stronger continuous acid filter usage.
; MUSICTHEORYFIX: lead/arp quantized to bass-root minor pentatonic with smoother acid intervals.
; FINALCOMPLETE: final hard-acid no-intro extended peak release, cleaned and audited.
; HARDACID: all sections use acid filter flag; start SLOT4 + peak SLOT10-15
        !byte $11,$11,$11,$02,$12,$12,$12,$02,$13,$13,$13,$02,$14,$14,$14,$02
        !byte $15,$15,$15,$02,$16,$16,$16,$02,$17,$17,$17,$02,$18,$18,$18,$02
        !byte $19,$19,$19,$02,$1a,$1a,$1a,$02,$1b,$1b,$1b,$02,$1c,$1c,$1c,$02
        !byte $1d,$1d,$1d,$02,$1e,$1e,$1e,$02,$1f,$1f,$1f,$02,$20,$20,$20,$02
        !byte $21,$21,$21,$02,$22,$22,$22,$02,$23,$23,$23,$02,$24,$24,$24,$02
        !byte $25,$25,$25,$02,$26,$26,$26,$02,$27,$27,$27,$02,$28,$28,$28,$02
        !byte $29,$29,$29,$02,$2a,$2a,$2a,$02,$2b,$2b,$2b,$02,$2c,$2c,$2c,$02
        !byte $2d,$2d,$2d,$02,$2e,$2e,$2e,$02,$2f,$2f,$2f,$02,$30,$30,$30,$02
        !byte $31,$31,$31,$02,$32,$32,$32,$02,$33,$33,$33,$02,$34,$34,$34,$02
        !byte $35,$35,$35,$02,$36,$36,$36,$02,$37,$37,$37,$02,$38,$38,$38,$02
        !byte $39,$39,$39,$02,$3a,$3a,$3a,$02,$3b,$3b,$3b,$02,$3c,$3c,$3c,$02
        !byte $25,$25,$25,$02,$26,$26,$26,$02,$27,$27,$27,$02,$28,$28,$28,$02
        !byte $29,$29,$29,$02,$2a,$2a,$2a,$02,$2b,$2b,$2b,$02,$2c,$2c,$2c,$02
        !byte $2d,$2d,$2d,$02,$2e,$2e,$2e,$02,$2f,$2f,$2f,$02,$30,$30,$30,$02
        !byte $31,$31,$31,$02,$32,$32,$32,$02,$33,$33,$33,$02,$34,$34,$34,$02
        !byte $35,$35,$35,$02,$36,$36,$36,$02,$37,$37,$37,$02,$38,$38,$38,$02
        !byte $39,$39,$39,$02,$3a,$3a,$3a,$02,$3b,$3b,$3b,$02,$3c,$3c,$3c,$02
        !byte $ff
H_bsilent:
        !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
H_bslot01b0:
        !byte $09,$00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS BASS bar0 from music(5).txt
H_bslot01b1:
        !byte $09,$00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS BASS bar1 from music(5).txt
H_bslot01b2:
        !byte $11,$00,$00,$00,$00,$00,$00,$00,$1d,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS BASS bar2 from music(5).txt
H_bslot01b3:
        !byte $09,$00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS BASS bar3 from music(5).txt
H_bslot02b0:
        !byte $09,$00,$00,$15,$15,$00,$00,$00,$21,$00,$00,$15,$15,$00,$21,$00 ; SLOT 2 BERLINA BASS bar0 from music(5).txt
H_bslot02b1:
        !byte $09,$00,$00,$15,$15,$00,$00,$00,$21,$00,$00,$15,$15,$00,$21,$00 ; SLOT 2 BERLINA BASS bar1 from music(5).txt
H_bslot02b2:
        !byte $09,$00,$00,$15,$15,$00,$00,$00,$21,$00,$00,$15,$15,$00,$21,$00 ; SLOT 2 BERLINA BASS bar2 from music(5).txt
H_bslot02b3:
        !byte $11,$00,$00,$1d,$1d,$00,$00,$00,$29,$00,$00,$1d,$1d,$00,$29,$00 ; SLOT 2 BERLINA BASS bar3 from music(5).txt
H_bslot03b0:
        !byte $09,$00,$21,$15,$15,$00,$21,$15,$09,$00,$21,$15,$15,$00,$21,$1c ; SLOT 3 BERLINB BASS bar0 from music(5).txt
H_bslot03b1:
        !byte $11,$00,$29,$1d,$1d,$00,$29,$1d,$11,$00,$29,$1d,$1d,$00,$29,$24 ; SLOT 3 BERLINB BASS bar1 from music(5).txt
H_bslot03b2:
        !byte $13,$00,$2b,$1f,$1f,$00,$2b,$1f,$13,$00,$2b,$1f,$1f,$00,$2b,$26 ; SLOT 3 BERLINB BASS bar2 from music(5).txt
H_bslot03b3:
        !byte $09,$00,$21,$15,$15,$00,$21,$15,$09,$00,$21,$15,$15,$00,$21,$1c ; SLOT 3 BERLINB BASS bar3 from music(5).txt
H_bslot04b0:
        !byte $09,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00 ; SLOT 4 TECHNOA BASS bar0 from music(5).txt
H_bslot04b1:
        !byte $09,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00 ; SLOT 4 TECHNOA BASS bar1 from music(5).txt
H_bslot04b2:
        !byte $0e,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00 ; SLOT 4 TECHNOA BASS bar2 from music(5).txt
H_bslot04b3:
        !byte $0e,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00,$1a,$00 ; SLOT 4 TECHNOA BASS bar3 from music(5).txt
H_bslot05b0:
        !byte $09,$00,$15,$00,$15,$00,$21,$15,$09,$00,$15,$00,$15,$00,$21,$15 ; SLOT 5 TECHNOB BASS bar0 from music(5).txt
H_bslot05b1:
        !byte $13,$00,$1f,$00,$1f,$00,$2b,$1f,$13,$00,$1f,$00,$1f,$00,$2b,$1f ; SLOT 5 TECHNOB BASS bar1 from music(5).txt
H_bslot05b2:
        !byte $11,$00,$1d,$00,$1d,$00,$29,$1d,$11,$00,$1d,$00,$1d,$00,$29,$1d ; SLOT 5 TECHNOB BASS bar2 from music(5).txt
H_bslot05b3:
        !byte $13,$00,$1f,$00,$1f,$00,$2b,$1f,$13,$00,$1f,$00,$1f,$00,$2b,$1f ; SLOT 5 TECHNOB BASS bar3 from music(5).txt
H_bslot06b0:
        !byte $09,$15,$15,$21,$15,$15,$00,$21,$15,$15,$00,$21,$15,$15,$15,$1c ; SLOT 6 TECHNOC BASS bar0 from music(5).txt
H_bslot06b1:
        !byte $11,$1d,$1d,$29,$1d,$1d,$00,$29,$1d,$1d,$00,$29,$1d,$1d,$1d,$24 ; SLOT 6 TECHNOC BASS bar1 from music(5).txt
H_bslot06b2:
        !byte $0c,$18,$18,$24,$18,$18,$00,$24,$18,$18,$00,$24,$18,$18,$18,$1f ; SLOT 6 TECHNOC BASS bar2 from music(5).txt
H_bslot06b3:
        !byte $13,$1f,$1f,$2b,$1f,$1f,$00,$2b,$1f,$1f,$00,$2b,$1f,$1f,$1f,$26 ; SLOT 6 TECHNOC BASS bar3 from music(5).txt
H_bslot07b0:
        !byte $09,$00,$00,$00,$00,$00,$15,$00,$09,$00,$00,$00,$00,$00,$15,$00 ; SLOT 7 DUBTEK BASS bar0 from music(5).txt
H_bslot07b1:
        !byte $09,$00,$00,$00,$00,$00,$15,$00,$09,$00,$00,$00,$00,$00,$15,$00 ; SLOT 7 DUBTEK BASS bar1 from music(5).txt
H_bslot07b2:
        !byte $09,$00,$00,$00,$00,$00,$15,$00,$09,$00,$00,$00,$00,$00,$15,$00 ; SLOT 7 DUBTEK BASS bar2 from music(5).txt
H_bslot07b3:
        !byte $11,$00,$00,$00,$00,$00,$1d,$00,$11,$00,$00,$00,$00,$00,$1d,$00 ; SLOT 7 DUBTEK BASS bar3 from music(5).txt
H_bslot08b0:
        !byte $09,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21 ; SLOT 8 ACIDROLL BASS bar0 from music(5).txt
H_bslot08b1:
        !byte $09,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21 ; SLOT 8 ACIDROLL BASS bar1 from music(5).txt
H_bslot08b2:
        !byte $0e,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26 ; SLOT 8 ACIDROLL BASS bar2 from music(5).txt
H_bslot08b3:
        !byte $0e,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26 ; SLOT 8 ACIDROLL BASS bar3 from music(5).txt
H_bslot09b0:
        !byte $09,$00,$00,$00,$15,$00,$21,$00,$09,$00,$00,$00,$15,$00,$21,$00 ; SLOT 9 DETROIT BASS bar0 from music(5).txt
H_bslot09b1:
        !byte $11,$00,$00,$00,$1d,$00,$29,$00,$11,$00,$00,$00,$1d,$00,$29,$00 ; SLOT 9 DETROIT BASS bar1 from music(5).txt
H_bslot09b2:
        !byte $0c,$00,$00,$00,$18,$00,$24,$00,$0c,$00,$00,$00,$18,$00,$24,$00 ; SLOT 9 DETROIT BASS bar2 from music(5).txt
H_bslot09b3:
        !byte $13,$00,$00,$00,$1f,$00,$2b,$00,$13,$00,$00,$00,$1f,$00,$2b,$00 ; SLOT 9 DETROIT BASS bar3 from music(5).txt
H_bslot10b0:
        !byte $09,$15,$15,$21,$15,$15,$00,$21,$15,$15,$00,$21,$15,$15,$15,$21 ; SLOT 10 RAVEPEAK BASS bar0 from music(5).txt
H_bslot10b1:
        !byte $11,$1d,$1d,$29,$1d,$1d,$00,$29,$1d,$1d,$00,$29,$1d,$1d,$1d,$29 ; SLOT 10 RAVEPEAK BASS bar1 from music(5).txt
H_bslot10b2:
        !byte $13,$1f,$1f,$2b,$1f,$1f,$00,$2b,$1f,$1f,$00,$2b,$1f,$1f,$1f,$2b ; SLOT 10 RAVEPEAK BASS bar2 from music(5).txt
H_bslot10b3:
        !byte $09,$15,$15,$21,$15,$15,$00,$21,$15,$15,$00,$21,$15,$15,$15,$21 ; SLOT 10 RAVEPEAK BASS bar3 from music(5).txt
H_bslot11b0:
        !byte $09,$15,$00,$21,$15,$15,$00,$21,$09,$15,$00,$21,$15,$15,$00,$21 ; SLOT 11 SWEEP BASS bar0 from music(5).txt
H_bslot11b1:
        !byte $09,$15,$00,$21,$15,$15,$00,$21,$09,$15,$00,$21,$15,$15,$00,$21 ; SLOT 11 SWEEP BASS bar1 from music(5).txt
H_bslot11b2:
        !byte $09,$15,$00,$21,$15,$15,$00,$21,$09,$15,$00,$21,$15,$15,$00,$21 ; SLOT 11 SWEEP BASS bar2 from music(5).txt
H_bslot11b3:
        !byte $09,$15,$00,$21,$15,$15,$00,$21,$09,$15,$00,$21,$15,$15,$00,$21 ; SLOT 11 SWEEP BASS bar3 from music(5).txt
H_bslot12b0:
        !byte $09,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00 ; SLOT 12 RING BASS bar0 from music(5).txt
H_bslot12b1:
        !byte $09,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00 ; SLOT 12 RING BASS bar1 from music(5).txt
H_bslot12b2:
        !byte $13,$00,$1f,$00,$1f,$00,$1f,$00,$1f,$00,$1f,$00,$1f,$00,$1f,$00 ; SLOT 12 RING BASS bar2 from music(5).txt
H_bslot12b3:
        !byte $09,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00,$15,$00 ; SLOT 12 RING BASS bar3 from music(5).txt
H_bslot13b0:
        !byte $09,$00,$15,$00,$15,$00,$21,$00,$09,$00,$15,$00,$15,$00,$21,$00 ; SLOT 13 SYNCL BASS bar0 from music(5).txt
H_bslot13b1:
        !byte $11,$00,$1d,$00,$1d,$00,$29,$00,$11,$00,$1d,$00,$1d,$00,$29,$00 ; SLOT 13 SYNCL BASS bar1 from music(5).txt
H_bslot13b2:
        !byte $13,$00,$1f,$00,$1f,$00,$2b,$00,$13,$00,$1f,$00,$1f,$00,$2b,$00 ; SLOT 13 SYNCL BASS bar2 from music(5).txt
H_bslot13b3:
        !byte $09,$00,$15,$00,$15,$00,$21,$00,$09,$00,$15,$00,$15,$00,$21,$00 ; SLOT 13 SYNCL BASS bar3 from music(5).txt
H_bslot14b0:
        !byte $09,$00,$15,$21,$00,$00,$15,$00,$09,$00,$15,$21,$00,$00,$15,$00 ; SLOT 14 GATET BASS bar0 from music(5).txt
H_bslot14b1:
        !byte $09,$00,$15,$21,$00,$00,$15,$00,$09,$00,$15,$21,$00,$00,$15,$00 ; SLOT 14 GATET BASS bar1 from music(5).txt
H_bslot14b2:
        !byte $11,$00,$1d,$29,$00,$00,$1d,$00,$11,$00,$1d,$29,$00,$00,$1d,$00 ; SLOT 14 GATET BASS bar2 from music(5).txt
H_bslot14b3:
        !byte $11,$00,$1d,$29,$00,$00,$1d,$00,$11,$00,$1d,$29,$00,$00,$1d,$00 ; SLOT 14 GATET BASS bar3 from music(5).txt
H_bslot15b0:
        !byte $09,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21 ; SLOT 15 ACIDMAX BASS bar0 from music(5).txt
H_bslot15b1:
        !byte $09,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21,$15,$00,$15,$21 ; SLOT 15 ACIDMAX BASS bar1 from music(5).txt
H_bslot15b2:
        !byte $0e,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26 ; SLOT 15 ACIDMAX BASS bar2 from music(5).txt
H_bslot15b3:
        !byte $0e,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26,$1a,$00,$1a,$26 ; SLOT 15 ACIDMAX BASS bar3 from music(5).txt
H_dsilent:
        !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
H_dslot01b0:
        !byte $01,$00,$02,$00,$01,$00,$00,$00,$01,$00,$02,$00,$01,$00,$00,$00 ; SLOT 1 AFTERHOURS DRUM bar0 from music(5).txt
H_dslot01b1:
        !byte $01,$00,$02,$00,$01,$00,$00,$00,$01,$00,$02,$00,$01,$00,$00,$00 ; SLOT 1 AFTERHOURS DRUM bar1 from music(5).txt
H_dslot01b2:
        !byte $01,$00,$02,$00,$01,$00,$00,$00,$01,$00,$02,$00,$01,$00,$00,$00 ; SLOT 1 AFTERHOURS DRUM bar2 from music(5).txt
H_dslot01b3:
        !byte $01,$00,$02,$00,$01,$00,$00,$00,$01,$00,$02,$00,$01,$00,$00,$00 ; SLOT 1 AFTERHOURS DRUM bar3 from music(5).txt
H_dslot02b0:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 2 BERLINA DRUM bar0 from music(5).txt
H_dslot02b1:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 2 BERLINA DRUM bar1 from music(5).txt
H_dslot02b2:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 2 BERLINA DRUM bar2 from music(5).txt
H_dslot02b3:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 2 BERLINA DRUM bar3 from music(5).txt
H_dslot03b0:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 3 BERLINB DRUM bar0 from music(5).txt
H_dslot03b1:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 3 BERLINB DRUM bar1 from music(5).txt
H_dslot03b2:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 3 BERLINB DRUM bar2 from music(5).txt
H_dslot03b3:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 3 BERLINB DRUM bar3 from music(5).txt
H_dslot04b0:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 4 TECHNOA DRUM bar0 from music(5).txt
H_dslot04b1:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 4 TECHNOA DRUM bar1 from music(5).txt
H_dslot04b2:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 4 TECHNOA DRUM bar2 from music(5).txt
H_dslot04b3:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 4 TECHNOA DRUM bar3 from music(5).txt
H_dslot05b0:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 5 TECHNOB DRUM bar0 from music(5).txt
H_dslot05b1:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 5 TECHNOB DRUM bar1 from music(5).txt
H_dslot05b2:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 5 TECHNOB DRUM bar2 from music(5).txt
H_dslot05b3:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 5 TECHNOB DRUM bar3 from music(5).txt
H_dslot06b0:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 6 TECHNOC DRUM bar0 from music(5).txt
H_dslot06b1:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 6 TECHNOC DRUM bar1 from music(5).txt
H_dslot06b2:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 6 TECHNOC DRUM bar2 from music(5).txt
H_dslot06b3:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 6 TECHNOC DRUM bar3 from music(5).txt
H_dslot07b0:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 7 DUBTEK DRUM bar0 from music(5).txt
H_dslot07b1:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 7 DUBTEK DRUM bar1 from music(5).txt
H_dslot07b2:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 7 DUBTEK DRUM bar2 from music(5).txt
H_dslot07b3:
        !byte $01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02,$00 ; SLOT 7 DUBTEK DRUM bar3 from music(5).txt
H_dslot08b0:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 8 ACIDROLL DRUM bar0 from music(5).txt
H_dslot08b1:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 8 ACIDROLL DRUM bar1 from music(5).txt
H_dslot08b2:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 8 ACIDROLL DRUM bar2 from music(5).txt
H_dslot08b3:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 8 ACIDROLL DRUM bar3 from music(5).txt
H_dslot09b0:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 9 DETROIT DRUM bar0 from music(5).txt
H_dslot09b1:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 9 DETROIT DRUM bar1 from music(5).txt
H_dslot09b2:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 9 DETROIT DRUM bar2 from music(5).txt
H_dslot09b3:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 9 DETROIT DRUM bar3 from music(5).txt
H_dslot10b0:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 10 RAVEPEAK DRUM bar0 from music(5).txt
H_dslot10b1:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 10 RAVEPEAK DRUM bar1 from music(5).txt
H_dslot10b2:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 10 RAVEPEAK DRUM bar2 from music(5).txt
H_dslot10b3:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 10 RAVEPEAK DRUM bar3 from music(5).txt
H_dslot11b0:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 11 SWEEP DRUM bar0 from music(5).txt
H_dslot11b1:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 11 SWEEP DRUM bar1 from music(5).txt
H_dslot11b2:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 11 SWEEP DRUM bar2 from music(5).txt
H_dslot11b3:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 11 SWEEP DRUM bar3 from music(5).txt
H_dslot12b0:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 12 RING DRUM bar0 from music(5).txt
H_dslot12b1:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 12 RING DRUM bar1 from music(5).txt
H_dslot12b2:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 12 RING DRUM bar2 from music(5).txt
H_dslot12b3:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 12 RING DRUM bar3 from music(5).txt
H_dslot13b0:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 13 SYNCL DRUM bar0 from music(5).txt
H_dslot13b1:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 13 SYNCL DRUM bar1 from music(5).txt
H_dslot13b2:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 13 SYNCL DRUM bar2 from music(5).txt
H_dslot13b3:
        !byte $01,$00,$02,$00,$03,$00,$02,$00,$01,$00,$02,$00,$03,$00,$02,$00 ; SLOT 13 SYNCL DRUM bar3 from music(5).txt
H_dslot14b0:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 14 GATET DRUM bar0 from music(5).txt
H_dslot14b1:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 14 GATET DRUM bar1 from music(5).txt
H_dslot14b2:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 14 GATET DRUM bar2 from music(5).txt
H_dslot14b3:
        !byte $01,$02,$02,$02,$03,$02,$02,$02,$01,$02,$02,$02,$03,$02,$02,$02 ; SLOT 14 GATET DRUM bar3 from music(5).txt
H_dslot15b0:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 15 ACIDMAX DRUM bar0 from music(5).txt
H_dslot15b1:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 15 ACIDMAX DRUM bar1 from music(5).txt
H_dslot15b2:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 15 ACIDMAX DRUM bar2 from music(5).txt
H_dslot15b3:
        !byte $01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02,$01,$02,$02,$02 ; SLOT 15 ACIDMAX DRUM bar3 from music(5).txt
H_lsilent:
        !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
H_lslot01b0:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS LEAD bar0 from music(5).txt
H_lslot01b1:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS LEAD bar1 from music(5).txt
H_lslot01b2:
        !byte $34,$00,$00,$00,$00,$00,$00,$00,$34,$00,$00,$00,$00,$00,$00,$00 ; MUSIC THEORY FIX slot01 bar2 root=$09 minor-pentatonic acid
H_lslot01b3:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00 ; SLOT 1 AFTERHOURS LEAD bar3 from music(5).txt
H_lslot02b0:
        !byte $00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00 ; SLOT 2 BERLINA LEAD bar0 from music(5).txt
H_lslot02b1:
        !byte $00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00 ; SLOT 2 BERLINA LEAD bar1 from music(5).txt
H_lslot02b2:
        !byte $00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00 ; SLOT 2 BERLINA LEAD bar2 from music(5).txt
H_lslot02b3:
        !byte $00,$00,$00,$00,$00,$00,$34,$00,$00,$00,$00,$00,$00,$00,$34,$00 ; MUSIC THEORY FIX slot02 bar3 root=$09 minor-pentatonic acid
H_lslot03b0:
        !byte $00,$00,$2d,$00,$00,$00,$2d,$2d,$00,$00,$2d,$00,$00,$00,$2d,$2d ; MUSIC THEORY FIX slot03 bar0 root=$09 minor-pentatonic acid
H_lslot03b1:
        !byte $00,$00,$34,$00,$00,$00,$34,$34,$00,$00,$34,$00,$00,$00,$34,$34 ; MUSIC THEORY FIX slot03 bar1 root=$09 minor-pentatonic acid
H_lslot03b2:
        !byte $00,$00,$37,$00,$00,$00,$37,$37,$00,$00,$37,$00,$00,$00,$37,$37 ; MUSIC THEORY FIX slot03 bar2 root=$09 minor-pentatonic acid
H_lslot03b3:
        !byte $00,$00,$2d,$00,$00,$00,$2d,$2d,$00,$00,$2d,$00,$00,$00,$2d,$2d ; MUSIC THEORY FIX slot03 bar3 root=$09 minor-pentatonic acid
H_lslot04b0:
        !byte $2d,$28,$2d,$32,$34,$34,$39,$39,$3e,$40,$40,$45,$4a,$4c,$4a,$4c ; MUSIC THEORY FIX slot04 bar0 root=$09 minor-pentatonic acid
H_lslot04b1:
        !byte $2d,$2d,$32,$2d,$28,$28,$26,$21,$1c,$2d,$32,$2d,$28,$26,$21,$2d ; MUSIC THEORY FIX slot04 bar1 root=$09 minor-pentatonic acid
H_lslot04b2:
        !byte $32,$30,$32,$37,$32,$30,$30,$32,$32,$30,$2b,$26,$26,$24,$1f,$30 ; MUSIC THEORY FIX slot04 bar2 root=$09 minor-pentatonic acid
H_lslot04b3:
        !byte $32,$30,$32,$37,$32,$30,$30,$32,$32,$30,$2b,$26,$26,$24,$1f,$30 ; MUSIC THEORY FIX slot04 bar3 root=$09 minor-pentatonic acid
H_lslot05b0:
        !byte $2d,$00,$00,$2d,$00,$00,$28,$00,$26,$00,$00,$21,$00,$00,$26,$00 ; MUSIC THEORY FIX slot05 bar0 root=$09 minor-pentatonic acid
H_lslot05b1:
        !byte $37,$00,$00,$37,$00,$00,$34,$00,$30,$00,$00,$2b,$00,$00,$30,$00 ; MUSIC THEORY FIX slot05 bar1 root=$09 minor-pentatonic acid
H_lslot05b2:
        !byte $34,$00,$00,$34,$00,$00,$32,$00,$30,$00,$00,$34,$00,$00,$30,$00 ; MUSIC THEORY FIX slot05 bar2 root=$09 minor-pentatonic acid
H_lslot05b3:
        !byte $37,$00,$00,$37,$00,$00,$34,$00,$30,$00,$00,$2b,$00,$00,$30,$00 ; MUSIC THEORY FIX slot05 bar3 root=$09 minor-pentatonic acid
H_lslot06b0:
        !byte $39,$00,$00,$39,$00,$00,$39,$00,$39,$00,$00,$39,$00,$00,$39,$00 ; SLOT 6 TECHNOC LEAD bar0 from music(5).txt
H_lslot06b1:
        !byte $40,$00,$00,$40,$00,$00,$40,$00,$40,$00,$00,$40,$00,$00,$40,$00 ; MUSIC THEORY FIX slot06 bar1 root=$09 minor-pentatonic acid
H_lslot06b2:
        !byte $3c,$00,$00,$3c,$00,$00,$3c,$00,$3c,$00,$00,$3c,$00,$00,$3c,$00 ; SLOT 6 TECHNOC LEAD bar2 from music(5).txt
H_lslot06b3:
        !byte $43,$00,$00,$43,$00,$00,$43,$00,$43,$00,$00,$43,$00,$00,$43,$00 ; SLOT 6 TECHNOC LEAD bar3 from music(5).txt
H_lslot07b0:
        !byte $00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00 ; SLOT 7 DUBTEK LEAD bar0 from music(5).txt
H_lslot07b1:
        !byte $00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00 ; SLOT 7 DUBTEK LEAD bar1 from music(5).txt
H_lslot07b2:
        !byte $00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$2d,$00 ; SLOT 7 DUBTEK LEAD bar2 from music(5).txt
H_lslot07b3:
        !byte $00,$00,$00,$00,$00,$00,$34,$00,$00,$00,$00,$00,$00,$00,$34,$00 ; MUSIC THEORY FIX slot07 bar3 root=$09 minor-pentatonic acid
H_lslot08b0:
        !byte $2d,$2d,$2d,$2d,$28,$2d,$2d,$28,$2d,$32,$2d,$2d,$28,$2d,$28,$2d ; MUSIC THEORY FIX slot08 bar0 root=$09 minor-pentatonic acid
H_lslot08b1:
        !byte $2d,$2d,$2d,$2d,$28,$2d,$2d,$28,$2d,$32,$2d,$2d,$28,$2d,$28,$2d ; MUSIC THEORY FIX slot08 bar1 root=$09 minor-pentatonic acid
H_lslot08b2:
        !byte $32,$32,$32,$32,$30,$32,$32,$30,$32,$37,$32,$32,$30,$32,$30,$32 ; MUSIC THEORY FIX slot08 bar2 root=$09 minor-pentatonic acid
H_lslot08b3:
        !byte $32,$32,$32,$32,$30,$32,$32,$30,$32,$37,$32,$32,$30,$32,$30,$32 ; MUSIC THEORY FIX slot08 bar3 root=$09 minor-pentatonic acid
H_lslot09b0:
        !byte $2d,$00,$30,$00,$34,$00,$00,$30,$34,$00,$00,$39,$34,$00,$34,$00 ; MUSIC THEORY FIX slot09 bar0 root=$09 minor-pentatonic acid
H_lslot09b1:
        !byte $34,$00,$39,$00,$3c,$00,$00,$39,$3c,$00,$00,$40,$3e,$00,$3c,$00 ; MUSIC THEORY FIX slot09 bar1 root=$09 minor-pentatonic acid
H_lslot09b2:
        !byte $30,$00,$34,$00,$37,$00,$00,$34,$37,$00,$00,$3c,$39,$00,$37,$00 ; SLOT 9 DETROIT LEAD bar2 from music(5).txt
H_lslot09b3:
        !byte $37,$00,$3c,$00,$3e,$00,$00,$3c,$3e,$00,$00,$43,$40,$00,$3e,$00 ; MUSIC THEORY FIX slot09 bar3 root=$09 minor-pentatonic acid
H_lslot10b0:
        !byte $39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39 ; SLOT 10 RAVEPEAK LEAD bar0 from music(5).txt
H_lslot10b1:
        !byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40 ; MUSIC THEORY FIX slot10 bar1 root=$09 minor-pentatonic acid
H_lslot10b2:
        !byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43 ; SLOT 10 RAVEPEAK LEAD bar2 from music(5).txt
H_lslot10b3:
        !byte $39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39 ; SLOT 10 RAVEPEAK LEAD bar3 from music(5).txt
H_lslot11b0:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; SLOT 11 SWEEP LEAD bar0 from music(5).txt
H_lslot11b1:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; SLOT 11 SWEEP LEAD bar1 from music(5).txt
H_lslot11b2:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; SLOT 11 SWEEP LEAD bar2 from music(5).txt
H_lslot11b3:
        !byte $2d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; SLOT 11 SWEEP LEAD bar3 from music(5).txt
H_lslot12b0:
        !byte $2d,$2d,$2d,$2d,$28,$2d,$2d,$2d,$2d,$28,$2d,$2d,$28,$2d,$2d,$28 ; MUSIC THEORY FIX slot12 bar0 root=$09 minor-pentatonic acid
H_lslot12b1:
        !byte $2d,$2d,$2d,$2d,$28,$2d,$2d,$2d,$2d,$28,$2d,$2d,$28,$2d,$2d,$28 ; MUSIC THEORY FIX slot12 bar1 root=$09 minor-pentatonic acid
H_lslot12b2:
        !byte $37,$37,$37,$37,$32,$37,$37,$37,$37,$34,$37,$37,$32,$37,$37,$34 ; MUSIC THEORY FIX slot12 bar2 root=$09 minor-pentatonic acid
H_lslot12b3:
        !byte $2d,$2d,$2d,$2d,$28,$2d,$2d,$2d,$2d,$28,$2d,$2d,$28,$2d,$2d,$28 ; MUSIC THEORY FIX slot12 bar3 root=$09 minor-pentatonic acid
H_lslot13b0:
        !byte $39,$00,$00,$00,$34,$00,$00,$00,$34,$00,$00,$00,$39,$00,$00,$00 ; MUSIC THEORY FIX slot13 bar0 root=$09 minor-pentatonic acid
H_lslot13b1:
        !byte $40,$00,$00,$00,$3e,$00,$00,$00,$3c,$00,$00,$00,$40,$00,$00,$00 ; MUSIC THEORY FIX slot13 bar1 root=$09 minor-pentatonic acid
H_lslot13b2:
        !byte $43,$00,$00,$00,$40,$00,$00,$00,$3e,$00,$00,$00,$43,$00,$00,$00 ; SLOT 13 SYNCL LEAD bar2 from music(5).txt
H_lslot13b3:
        !byte $39,$00,$00,$00,$34,$00,$00,$00,$34,$00,$00,$00,$39,$00,$00,$00 ; MUSIC THEORY FIX slot13 bar3 root=$09 minor-pentatonic acid
H_lslot14b0:
        !byte $2d,$00,$2d,$2d,$00,$2d,$2d,$00,$2d,$00,$2d,$2d,$00,$2d,$00,$2d ; SLOT 14 GATET LEAD bar0 from music(5).txt
H_lslot14b1:
        !byte $2d,$00,$2d,$2d,$00,$2d,$2d,$00,$2d,$00,$2d,$2d,$00,$2d,$00,$2d ; SLOT 14 GATET LEAD bar1 from music(5).txt
H_lslot14b2:
        !byte $34,$00,$34,$34,$00,$34,$34,$00,$34,$00,$34,$34,$00,$34,$00,$34 ; MUSIC THEORY FIX slot14 bar2 root=$09 minor-pentatonic acid
H_lslot14b3:
        !byte $34,$00,$34,$34,$00,$34,$34,$00,$34,$00,$34,$34,$00,$34,$00,$34 ; MUSIC THEORY FIX slot14 bar3 root=$09 minor-pentatonic acid
H_lslot15b0:
        !byte $2d,$28,$26,$21,$1c,$21,$28,$2d,$28,$28,$2d,$32,$32,$34,$39,$39 ; MUSIC THEORY FIX slot15 bar0 root=$09 minor-pentatonic acid
H_lslot15b1:
        !byte $2d,$2d,$32,$2d,$28,$28,$30,$2d,$28,$28,$2d,$32,$32,$30,$34,$39 ; MUSIC THEORY FIX slot15 bar1 root=$09 minor-pentatonic acid
H_lslot15b2:
        !byte $32,$30,$32,$32,$37,$32,$30,$32,$30,$30,$32,$32,$37,$3c,$3e,$3e ; MUSIC THEORY FIX slot15 bar2 root=$09 minor-pentatonic acid
H_lslot15b3:
        !byte $32,$30,$32,$32,$37,$32,$30,$32,$30,$30,$32,$32,$37,$3c,$3e,$3e ; MUSIC THEORY FIX slot15 bar3 root=$09 minor-pentatonic acid
H_bpat_lo:
        !byte <H_bsilent,<H_bslot01b0,<H_bslot01b1,<H_bslot01b2,<H_bslot01b3,<H_bslot02b0,<H_bslot02b1,<H_bslot02b2,<H_bslot02b3,<H_bslot03b0,<H_bslot03b1,<H_bslot03b2,<H_bslot03b3,<H_bslot04b0,<H_bslot04b1,<H_bslot04b2,<H_bslot04b3,<H_bslot05b0,<H_bslot05b1,<H_bslot05b2,<H_bslot05b3,<H_bslot06b0,<H_bslot06b1,<H_bslot06b2,<H_bslot06b3,<H_bslot07b0,<H_bslot07b1,<H_bslot07b2,<H_bslot07b3,<H_bslot08b0,<H_bslot08b1,<H_bslot08b2,<H_bslot08b3,<H_bslot09b0,<H_bslot09b1,<H_bslot09b2,<H_bslot09b3,<H_bslot10b0,<H_bslot10b1,<H_bslot10b2,<H_bslot10b3,<H_bslot11b0,<H_bslot11b1,<H_bslot11b2,<H_bslot11b3,<H_bslot12b0,<H_bslot12b1,<H_bslot12b2,<H_bslot12b3,<H_bslot13b0,<H_bslot13b1,<H_bslot13b2,<H_bslot13b3,<H_bslot14b0,<H_bslot14b1,<H_bslot14b2,<H_bslot14b3,<H_bslot15b0,<H_bslot15b1,<H_bslot15b2,<H_bslot15b3
H_bpat_hi:
        !byte >H_bsilent,>H_bslot01b0,>H_bslot01b1,>H_bslot01b2,>H_bslot01b3,>H_bslot02b0,>H_bslot02b1,>H_bslot02b2,>H_bslot02b3,>H_bslot03b0,>H_bslot03b1,>H_bslot03b2,>H_bslot03b3,>H_bslot04b0,>H_bslot04b1,>H_bslot04b2,>H_bslot04b3,>H_bslot05b0,>H_bslot05b1,>H_bslot05b2,>H_bslot05b3,>H_bslot06b0,>H_bslot06b1,>H_bslot06b2,>H_bslot06b3,>H_bslot07b0,>H_bslot07b1,>H_bslot07b2,>H_bslot07b3,>H_bslot08b0,>H_bslot08b1,>H_bslot08b2,>H_bslot08b3,>H_bslot09b0,>H_bslot09b1,>H_bslot09b2,>H_bslot09b3,>H_bslot10b0,>H_bslot10b1,>H_bslot10b2,>H_bslot10b3,>H_bslot11b0,>H_bslot11b1,>H_bslot11b2,>H_bslot11b3,>H_bslot12b0,>H_bslot12b1,>H_bslot12b2,>H_bslot12b3,>H_bslot13b0,>H_bslot13b1,>H_bslot13b2,>H_bslot13b3,>H_bslot14b0,>H_bslot14b1,>H_bslot14b2,>H_bslot14b3,>H_bslot15b0,>H_bslot15b1,>H_bslot15b2,>H_bslot15b3
H_dpat_lo:
        !byte <H_dsilent,<H_dslot01b0,<H_dslot01b1,<H_dslot01b2,<H_dslot01b3,<H_dslot02b0,<H_dslot02b1,<H_dslot02b2,<H_dslot02b3,<H_dslot03b0,<H_dslot03b1,<H_dslot03b2,<H_dslot03b3,<H_dslot04b0,<H_dslot04b1,<H_dslot04b2,<H_dslot04b3,<H_dslot05b0,<H_dslot05b1,<H_dslot05b2,<H_dslot05b3,<H_dslot06b0,<H_dslot06b1,<H_dslot06b2,<H_dslot06b3,<H_dslot07b0,<H_dslot07b1,<H_dslot07b2,<H_dslot07b3,<H_dslot08b0,<H_dslot08b1,<H_dslot08b2,<H_dslot08b3,<H_dslot09b0,<H_dslot09b1,<H_dslot09b2,<H_dslot09b3,<H_dslot10b0,<H_dslot10b1,<H_dslot10b2,<H_dslot10b3,<H_dslot11b0,<H_dslot11b1,<H_dslot11b2,<H_dslot11b3,<H_dslot12b0,<H_dslot12b1,<H_dslot12b2,<H_dslot12b3,<H_dslot13b0,<H_dslot13b1,<H_dslot13b2,<H_dslot13b3,<H_dslot14b0,<H_dslot14b1,<H_dslot14b2,<H_dslot14b3,<H_dslot15b0,<H_dslot15b1,<H_dslot15b2,<H_dslot15b3
H_dpat_hi:
        !byte >H_dsilent,>H_dslot01b0,>H_dslot01b1,>H_dslot01b2,>H_dslot01b3,>H_dslot02b0,>H_dslot02b1,>H_dslot02b2,>H_dslot02b3,>H_dslot03b0,>H_dslot03b1,>H_dslot03b2,>H_dslot03b3,>H_dslot04b0,>H_dslot04b1,>H_dslot04b2,>H_dslot04b3,>H_dslot05b0,>H_dslot05b1,>H_dslot05b2,>H_dslot05b3,>H_dslot06b0,>H_dslot06b1,>H_dslot06b2,>H_dslot06b3,>H_dslot07b0,>H_dslot07b1,>H_dslot07b2,>H_dslot07b3,>H_dslot08b0,>H_dslot08b1,>H_dslot08b2,>H_dslot08b3,>H_dslot09b0,>H_dslot09b1,>H_dslot09b2,>H_dslot09b3,>H_dslot10b0,>H_dslot10b1,>H_dslot10b2,>H_dslot10b3,>H_dslot11b0,>H_dslot11b1,>H_dslot11b2,>H_dslot11b3,>H_dslot12b0,>H_dslot12b1,>H_dslot12b2,>H_dslot12b3,>H_dslot13b0,>H_dslot13b1,>H_dslot13b2,>H_dslot13b3,>H_dslot14b0,>H_dslot14b1,>H_dslot14b2,>H_dslot14b3,>H_dslot15b0,>H_dslot15b1,>H_dslot15b2,>H_dslot15b3
H_lpat_lo:
        !byte <H_lsilent,<H_lslot01b0,<H_lslot01b1,<H_lslot01b2,<H_lslot01b3,<H_lslot02b0,<H_lslot02b1,<H_lslot02b2,<H_lslot02b3,<H_lslot03b0,<H_lslot03b1,<H_lslot03b2,<H_lslot03b3,<H_lslot04b0,<H_lslot04b1,<H_lslot04b2,<H_lslot04b3,<H_lslot05b0,<H_lslot05b1,<H_lslot05b2,<H_lslot05b3,<H_lslot06b0,<H_lslot06b1,<H_lslot06b2,<H_lslot06b3,<H_lslot07b0,<H_lslot07b1,<H_lslot07b2,<H_lslot07b3,<H_lslot08b0,<H_lslot08b1,<H_lslot08b2,<H_lslot08b3,<H_lslot09b0,<H_lslot09b1,<H_lslot09b2,<H_lslot09b3,<H_lslot10b0,<H_lslot10b1,<H_lslot10b2,<H_lslot10b3,<H_lslot11b0,<H_lslot11b1,<H_lslot11b2,<H_lslot11b3,<H_lslot12b0,<H_lslot12b1,<H_lslot12b2,<H_lslot12b3,<H_lslot13b0,<H_lslot13b1,<H_lslot13b2,<H_lslot13b3,<H_lslot14b0,<H_lslot14b1,<H_lslot14b2,<H_lslot14b3,<H_lslot15b0,<H_lslot15b1,<H_lslot15b2,<H_lslot15b3
H_lpat_hi:
        !byte >H_lsilent,>H_lslot01b0,>H_lslot01b1,>H_lslot01b2,>H_lslot01b3,>H_lslot02b0,>H_lslot02b1,>H_lslot02b2,>H_lslot02b3,>H_lslot03b0,>H_lslot03b1,>H_lslot03b2,>H_lslot03b3,>H_lslot04b0,>H_lslot04b1,>H_lslot04b2,>H_lslot04b3,>H_lslot05b0,>H_lslot05b1,>H_lslot05b2,>H_lslot05b3,>H_lslot06b0,>H_lslot06b1,>H_lslot06b2,>H_lslot06b3,>H_lslot07b0,>H_lslot07b1,>H_lslot07b2,>H_lslot07b3,>H_lslot08b0,>H_lslot08b1,>H_lslot08b2,>H_lslot08b3,>H_lslot09b0,>H_lslot09b1,>H_lslot09b2,>H_lslot09b3,>H_lslot10b0,>H_lslot10b1,>H_lslot10b2,>H_lslot10b3,>H_lslot11b0,>H_lslot11b1,>H_lslot11b2,>H_lslot11b3,>H_lslot12b0,>H_lslot12b1,>H_lslot12b2,>H_lslot12b3,>H_lslot13b0,>H_lslot13b1,>H_lslot13b2,>H_lslot13b3,>H_lslot14b0,>H_lslot14b1,>H_lslot14b2,>H_lslot14b3,>H_lslot15b0,>H_lslot15b1,>H_lslot15b2,>H_lslot15b3
H_freqlo:
        !byte $16,$27,$39,$4b,$5f,$74,$8a,$a1,$ba,$d4,$f0,$0e,$2d,$4e,$71,$96
        !byte $be,$e7,$14,$42,$74,$a9,$e0,$1b,$5a,$9c,$e2,$2d,$7b,$cf,$27,$85
        !byte $e8,$51,$c1,$37,$b4,$38,$c4,$59,$f7,$9d,$4e,$0a,$d0,$a2,$81,$6d
        !byte $67,$70,$89,$b2,$ed,$3b,$9c,$13,$a0,$45,$02,$da,$ce,$e0,$11,$64
        !byte $da,$76,$39,$26,$40,$89,$04,$b4,$9c,$c0,$23,$c8,$b4,$eb,$72,$4c
        !byte $80,$12,$08,$68,$39,$80,$45,$90,$68,$d6,$e3,$99,$00,$24,$10,$d0
H_freqhi:
        !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
        !byte $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06,$06
        !byte $06,$07,$07,$08,$08,$09,$09,$0a,$0a,$0b,$0c,$0d,$0d,$0e,$0f,$10
        !byte $11,$12,$13,$14,$15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$27,$29
        !byte $2b,$2e,$31,$34,$37,$3a,$3e,$41,$45,$49,$4e,$52,$57,$5c,$62,$68
        !byte $6e,$75,$7c,$83,$8b,$93,$9c,$a5,$af,$b9,$c4,$d0,$dd,$ea,$f8,$06

asset_end:
!if asset_end > $a000 {
        !error "Asset block crossed $a000."
}
