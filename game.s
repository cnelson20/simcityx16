.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
  jmp setup

.include "graphics.s"
.include "menu.s"

goBasic:        .byte $00
exitToMenu:     .byte $00
player_x:       .byte $00
player_y:       .byte $00

setup:
  jsr preserve_default_irq
  clc
  cld
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

  rts

@qPressed:
  lda #$00
  sta exitToMenu
  rts
@hPressed:
  ldx player_x
  ldy player_y
  ;jsr destroyBuilding;
  rts
@upPressed:
  ldx player_y
  cpx #$00
  beq @return
  dex
  stx player_y
  rts
@leftPressed:
  ldx player_x
  cpx #$00
  beq @return
  dex
  stx player_x
  rts
@downPressed:
  ldx player_y
  inx
  cpx #VIEWSIZE
  bcs @return
  stx player_y
  rts
@rightPressed:
  ldx player_x
  cpx #VIEWSIZE
  inx
  bcs @return
  stx player_x
  rts
@return:
  rts
