text_begin:
  .byte $10, $12, $05, $13, $13, $20, $01, $0E, $19, $20, $0B, $05, $19, $20, $14, $0F, $20, $0C, $0F, $01, $04, $20, $07, $01, $0D, $05
  ; length = 26
text_newgame:
  .byte $10, $12, $05, $13, $13, $20, $0E, $20, $06, $0F, $12, $20, $0E, $05, $17, $20, $07, $01, $0D, $05
  ; length = 20
text_title:
  .byte $20, $20, $0D, $01, $12, $13, $20, $18, $31, $36, $20, $20
  ; length = 12
switchHexTable:
  .incbin "table.bin"

map:
  .incbin "map.bin"
.DEFINE map_lobyte .LOBYTE (map)
.DEFINE map_hibyte .HIBYTE (map)

tiles:
  ;     wall?     character data                                                       ;
  ;     0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F   ;
  .byte $FF, $00, $6F, $6F, $77, $77, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Horizontal wall
  .byte $FF, $00, $6A, $74, $6A, $74, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Vertical wall
  .byte $FF, $00, $7A, $4C, $50, $4F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 4-way wall
  .byte $FF, $00, $6F, $20, $50, $65, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; SW wall connector
  .byte $FF, $00, $7A, $65, $77, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; NW wall connector
  .byte $FF, $00, $65, $4C, $20, $77, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; NE wall connector
  .byte $FF, $00, $20, $6F, $67, $4F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; SE wall connector
  .byte $00, $00, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; air / space

.DEFINE tiles_lobyte .LOBYTE (tiles)
.DEFINE tiles_hibyte .HIBYTE (tiles)
