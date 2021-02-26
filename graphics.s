.include "definitions.s"
.include "data.s"

money:
  .byte $00, $FF
view_x:
  .byte $00, VIEWSIZE
view_y:
  .byte $00, VIEWSIZE
xDraw:
  .byte $00
yDraw:
  .byte $00
xOffset:
  .byte $00
yOffset:
  .byte $00
temp:
  .byte $00
frameCounter:
  .byte $00
cursor_color:
  .byte COLOR_WHITE + COLOR_BACKGROUND_RED

Default_irq_handler:
  .byte $00, $00
preserve_default_irq:
  lda $0314
  sta Default_irq_handler
  lda $0315
  sta Default_irq_handler+1
  rts
restore_default_irq:
  sei
  lda Default_irq_handler
  sta $0314
  lda Default_irq_handler+1
  sta $0315
  cli
  rts
set_custom_irq_handler:
  sei
  lda #<custom_irq_handler
  sta $0314
  lda #>custom_irq_handler
  sta $0315
  cli
  rts

custom_irq_handler:
  lda $9F27
  and #$01
  beq irq_done

  ldx frameCounter
  inx
  stx frameCounter
  txa

  lsr
  bcs @keyboard
  lsr
  bcs @keyboard
  lsr
  bcs @keyboard
  lsr
  bcs @keyboard ; check if multiple of 16

  ldx cursor_color
  lda switchHexTable,X
  sta cursor_color
  @keyboard:
  ; get keyboard input ;
  jsr handleKeyboard
  ; go to game code or something ;
  jsr drawRoutine
  ; done ;

  ; Return to whatever had been interrupted:
  irq_done:
  jmp (Default_irq_handler)
  ; if that doesn't help ;

screenSetup:
  lda #$00
  sta yDraw ; set y variable to 0
  jsr @yLoop ; go to loop
  rts

@yLoop:
  ldx #$00
  stx xDraw ; store x variable to ram as 0
  jsr setXYaddr
  lda #$10
  sta VERA_autoInc ; set auto-increment to 1 byte
  jsr @xLoop
  ldy yDraw
  inc yDraw
  cpy #$3C ; compare to 60
  bne @yLoop
  rts

@xLoop:
  ldx #CHAR_SPACE
  stx VERA_dataAddr ; write text character
  jsr loadXColor
  stx VERA_dataAddr ; write color

  lda xDraw
  inc xDraw
  cmp #$50
  bne @xLoop
  rts

loadXColor:
  ldx #COLOR_WHITE
  lda xDraw ; load x (location) to accumulator
  clc
  cmp #$02 ; check if < 2
  bcc loadXLightGray
  adc #$4A ; add 72 (overflow set if >= 56)
  bvs loadXLightGray

  lda yDraw ; now load y
  clc
  cmp #$03
  bcc loadXLightGray
  adc #$4A ; same thing
  bvs loadXLightGray

  rts

loadXGray:
  ldx #COLOR_BACKGROUND_GRAY2
  rts
loadXLightGray:
  ldx #COLOR_BACKGROUND_GRAY3
  ; check if other gray should be there     ;
  ; bcc (or whatever) loadXLightGray  ;
  lda xDraw
  cmp #$3A
  bcc loadXGray
  cmp #$4B
  bcs loadXGray
  lda yDraw
  cmp #$06
  bcc loadXGray
  cmp #$30
  bcs loadXGray

  rts

; X is x pos and Y is y pos ;
setXYaddr:
  txa
  asl ; multiply by 2
  sta VERA_vramAddr0
  sty VERA_vramAddr1
  rts

clearPlayField:
  lda #$20
  sta VERA_autoInc
  lda #$02
  sta xDraw
  adc VIEWSIZE
  lda #$01
  sta yDraw
  @incY:
  clc
  inc yDraw
  ldy yDraw
  cpy # $02 + VIEWSIZE
  bcs @return
  ldx #$02
  stx xDraw
  jsr setXYaddr
  @loop:
  ldx xDraw
  cpx # $03 + VIEWSIZE
  bcs @incY

  lda #$20
  sta VERA_dataAddr

  inx
  stx xDraw
  jmp @loop
  @return:
  rts

; draw routine for main game ;
drawRoutine:
  ;do cursor ;
  ;draw rest of screen ;
  lda #$20
  sta VERA_autoInc

  lda #$00
  sta xDraw
  sta yDraw

  jmp @continue

  @incY:
  ldx #$00
  stx xDraw
  ldy yDraw
  iny ; increment
  sty yDraw

  cpy #VIEWSIZE_draw
  bcc @continue
  rts

  @continue:
  iny ; offset of two
  ldx #$02
  jsr setXYaddr
  @loop:
  jsr loadOffsetXY
  sta $20

  lda xDraw
  lsr
  tax
  lda yDraw
  lsr
  tay

  jsr loadAFromMap ; get character from map
  jsr setAddr30Tile ; set jmp address to that of tile

  clc
  lda #$02 ; characters of the tile start at offset $02
  adc $20 ; add what tile # we what
  tay
  lda ($30),Y
  cmp #$00
  beq @rt

  sta VERA_dataAddr

  ldx xDraw
  inx
  stx xDraw
  cpx #VIEWSIZE_draw
  bcs @incY
  jmp @loop

  @rt:
  rts


setAddr30Tile:
  ; this seems to work ;
  tax
  lda switchHexTable,X ; get A shifted four bytes from the table
  ; eg $2A -> $A2 ;
  sta $31
  and #$F0
  sta $30
  lda $31
  and #$0F
  sta $31

  clc ; clear carry cause fml ;

  lda $30
  adc #tiles_lobyte
  sta $30
  lda $31
  adc #tiles_hibyte
  sta $31
  rts

loadAFromMap:
  txa
  asl
  asl
  tax

  tya
  asl
  tay
  txa
  ror A
  tax

  tya
  asl
  tay
  txa
  ror A

  clc
  adc #map_lobyte
  sta $40
  tya
  adc #map_hibyte
  sta $41
  ldy #$00
  lda ($40),Y
  rts

storeAToMap:
  sta $42
  txa
  asl
  asl
  tax

  tya
  asl
  tay
  txa
  ror A
  tax

  tya
  asl
  tay
  txa
  ror A

  clc
  adc #map_lobyte
  sta $40
  tya
  adc #map_hibyte
  sta $41
  ldy #$00
  lda $42
  sta ($40),Y
  rts

loadOffsetXY:
  txa
  lsr
  bcs @Xmod1equals1
  tya
  lsr
  bcs @One
  lda #$00
  rts
@One:
  lda #$01
  rts
@Xmod1equals1:
  tya
  lsr
  bcs @Three
  ldx #$02
  rts
@Three:
  lda #$03
  rts
