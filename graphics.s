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
  jsr clearPlayField
  jsr drawRoutine
  ; done ;

  ;lda #$01
  ;sta $9F27
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
  clv ; clear overflow flag
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

drawCursor:
  ; fix color of last cursor
  lda cursor_moved
  cmp #$00
  beq @newCursor

  clc
  lda old_cursor_x
  adc #$02
  tax
  lda old_cursor_y
  adc #$02
  tay
  jsr setXYaddr
  inc VERA_vramAddr0
  lda # COLOR_WHITE
  sta VERA_dataAddr

  @newCursor:
  ; switch colors of current cursor ;
  clc
  lda cursor_x
  adc #$02
  tax
  lda cursor_y
  adc #$02
  tay
  jsr setXYaddr
  inc VERA_vramAddr0
  lda cursor_color
  sta VERA_dataAddr

  @return:
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
  jsr drawCursor
  ;draw rest of screen ;
  lda #$20
  sta VERA_autoInc

  lda #$00
  sta $80

  ; set X and Y to 0, store to memory ;
  ldx #$00
  stx temp

  ; draw screen ;
  @drawLoop:
  ldy #$00
  sty temp
  @loopHere:
  lda temp
  jsr setAddr32WithBuildingList

  ldy #$00
  lda ($32),Y
  cmp #$FF
  bne @buildingLoop
  rts

  @buildingLoop:
  cmp #$FE
  beq @incHere

  jsr drawObjectToScreen

  @incHere:
  inc temp
  jmp @loopHere

; .X & .Y are positions, .A building ID;
drawObjectToScreen:
  inx
  inx
  iny
  iny
  stx xDraw
  stx xOffset
  sty yDraw
  sty yOffset ; max position for x

  jsr setAddr30WithBuilding

  ldx xDraw
  ldy yDraw
  jsr setXYaddr

  clc
  ldy #$0A
  lda ($30),Y
  sta $3A
  cmp #$03
  bcc @a
  lda #$03
  @a:
  ; set max value for x ;

  lda #$20
  sta VERA_autoInc ; 2 bytes
  lda #$00
  sta $3B ; i
  sta $3C ; j
  sta $3D ; just a loop counter
  jsr @loop
  rts

  @incY:
  ldx #$00
  stx $3B ; set i to 0
  ldx xOffset
  stx xDraw
  inc yDraw
  ldy yDraw
  jsr setXYaddr
  clc
  ldy $3C
  iny
  sty $3C ; increment j
  cpy $3A ; check if j >= size
  bcs @return
  @loop:

  ldy $3D
  lda ($30),Y
  sta VERA_dataAddr

  @incX:
  inc $3D
  inc xDraw
  ldx $3B
  inx
  stx $3B ; increment i
  cpx $3A ; check if i >= size
  bcs @incY
  jmp @loop
  @return:
  rts

; x and y are the coordinates of what's to be drawn ;
; a is the building ID ;
createBuilding: ; draws buidling with id in the accumulator
  sta $34; building ID
  clc
  txa
  adc view_x
  stx xDraw
  clc
  tya
  adc view_x
  sty yDraw

  jsr setAddr30WithBuilding
  jsr findSpaceInList

  ; function call ;
  jsr memory_copy
  ldy #$01
  lda xDraw
  sta ($32),Y
  iny
  lda yDraw
  sta ($32),Y

  rts

; set X to 0 before ;
findSpaceInList:
  ldy #$00
  sty temp
  @loopHere:
  ldx temp
  cpx #$80
  bcc @checkLoop
  rts

  @checkLoop:
  lda temp
  jsr setAddr32WithBuildingList
  ldy #$00
  lda ($32),Y

  inc temp
  cmp #$FF
  beq @loopHere
  @return:
  rts

setAddr30WithBuilding:
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
  adc #building_lobyte
  sta $30
  lda $31
  adc #building_hibyte
  sta $31
  rts

setAddr32WithBuildingList:
  ; this seems to work ;
  tax
  lda switchHexTable,X ; get A shifted four bytes from the table
  ; eg $2A -> $A2 ;
  sta $33
  and #$F0
  sta $32
  lda $33
  and #$0F
  sta $33

  clc

  lda $32
  adc #list_lobyte
  sta $32
  lda $33
  adc #list_hibyte
  sta $33
  rts
