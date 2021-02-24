menu:
  jsr drawMenu
  jsr menu_loop
  rts

menu_loop:
  jsr keyboard_get
  and #$FF
  beq menu_loop
  eor #$4E
  beq new_save
  rts

new_save:
  ; create a new save game ;
  ; i will have to eventually put this in ;
  rts

drawMenu:
  lda #$10
  sta VERA_autoInc
  ldy #$00
  sty yDraw
  jsr menuY

  lda #$20
  sta VERA_autoInc ; set autoincrement to 2 bytes (skip color data)

  ldx #$22
  ldy #$17
  jsr setXYaddr
  ldx #$00
  jsr @writeTitle ; write SIM CITY X16 to screen

  ldx #$1B
  ldy #$1D
  jsr setXYaddr ; set VERA address to correct position
  ldx #$00 ; set x to 0, makes it easier to increment
  jsr @writeInstructions ; writes "PRESS ANY KEY TO BEGIN" on screen

  ldx #$1B
  ldy #$1B
  jsr setXYaddr
  ldx #$00
  jsr @writeNewGame ; write newgame instructions to the
  rts

@writeNewGame:
  lda text_newgame,X
  sta VERA_dataAddr
  inx
  cpx #$14
  bne @writeNewGame
  rts

@writeInstructions:
  lda text_begin,X ; load character x from beginning of array
  sta VERA_dataAddr
  inx ; increment x
  cpx #$1A ; compare against hex 1A
  bne @writeInstructions ; loop if < 26
  rts

@writeTitle:
  lda text_title,X ; load character x from beginning of array
  sta VERA_dataAddr
  inx ; increment x
  cpx #$0C ; compare against hex 0C
  bne @writeTitle ; loop if < 12
  rts

menuY:
  ldx #$00
  stx xDraw
  jsr setXYaddr
  jsr menuX
  iny
  cpy #$3C ; compare to 60
  bne menuY ; loop if not equal
  rts

menuX:
  lda #CHAR_SPACE
  sta VERA_dataAddr ; write text character

  jsr getMenuColor
  sta VERA_dataAddr ; write color

  inx
  cpx #$50 ; check if == 80
  bne menuX
  rts

getMenuColor:
  lda #$FF
  sta $0010
  lda #COLOR_BACKGROUND_GRAY2
  adc #COLOR_WHITE
  cpx #$3E
  bcs loadABlue
  cpx #$13
  bcc loadABlue
  cpy #$29
  bcs loadABlue
  cpy #$14
  bcc loadABlue

  bit $0010
  bne @checkBlack
  rts

@checkBlack:
  cpx #$3D
  beq loadABlack
  cpx #$13
  beq loadABlack
  cpy #$28
  beq loadABlack
  cpy #$14
  beq loadABlack
  rts

loadABlack:
  lda #COLOR_BLACK
  rts

loadABlue:
  lda #$00
  sta $0010
  lda #COLOR_BACKGROUND_BLUE
  rts
