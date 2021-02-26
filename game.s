.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
  jmp setup

.include "graphics.s"
.include "menu.s"

goBasic:        .byte $00
exitToMenu:     .byte $00
old_cursor_x:   .byte $00
old_cursor_y:   .byte $00
cursor_x:       .byte $00
cursor_y:       .byte $00
cursor_moved:   .byte $00

setup:
  jsr preserve_default_irq
  clc
  lda #$00
  sta list
  sta VERA_vramAddr0 ; clear vram addr
  sta VERA_vramAddr1 ; clear vram addr
  sta VERA_autoInc ; set auto-increment byte to 0
  lda #$01
  sta exitToMenu ; store 0 to continue so it doesnt loop
  lda #$00
  sta goBasic ; same so it exits to basic on loss
  jmp main

main:
  ; menu code ;
  jsr menu
  ; setup the game ;
  jsr screenSetup
  jsr setup_game
  ; go to main game ;
  jsr set_custom_irq_handler

  jsr loop1

  jsr restore_default_irq
  lda #$00 ; check if loop and whether to continue the loop
  cmp goBasic
  bne main

  sec ; Cold start for basic
  jmp $FF47; go back to basic

setup_game:
  ;create world;
  ldx #$02
  ldy #$02
  lda #$00
  jsr createBuilding

  rts

loop1:
  ; get keyboard input ;
  ; jsr handleKeyboard ;
  ; go to game code or something ;
  ; jsr drawRoutine ;

  lda #$00 ; check if loop and whether to continue the loop
  cmp exitToMenu
  bne loop1

  rts


handleKeyboard:
  lda #$00
  sta cursor_moved
  lda cursor_x
  sta old_cursor_x
  lda cursor_y
  sta old_cursor_y

  jsr keyboard_get
  ; check if you want to exit ;
  cmp #$51
  beq @qPressed
  ; check for demolish ;
  cmp #$48
  beq @hPressed
  ; cursor movement ;
  cmp #$57 ; w
  beq @upPressed
  cmp #$91 ; up
  beq @upPressed
  cmp #$41 ; s
  beq @leftPressed
  cmp #$9D ; left
  beq @leftPressed
  cmp #$53 ; a
  beq @downPressed
  cmp #$11 ; down
  beq @downPressed
  cmp #$44 ; d
  beq @rightPressed
  cmp #$1D ; right
  beq @rightPressed

  jmp @movementPart2

@qPressed:
  lda #$00
  sta exitToMenu
  rts
@hPressed:
  ldx cursor_x
  ldy cursor_y
  ;jsr destroyBuilding;
  rts
@upPressed:
  ldx cursor_y
  cpx #$00
  beq @return2
  dex
  stx cursor_y
  inc cursor_moved
  rts
@leftPressed:
  ldx cursor_x
  cpx #$00
  beq @return2
  dex
  stx cursor_x
  inc cursor_moved
  rts
@downPressed:
  ldx cursor_y
  inx
  cpx #VIEWSIZE
  bcs @return
  stx cursor_y
  inc cursor_moved
  rts
@rightPressed:
  ldx cursor_x
  cpx #VIEWSIZE
  inx
  bcs @return
  stx cursor_x
  inc cursor_moved
  rts
@return:
  rts
