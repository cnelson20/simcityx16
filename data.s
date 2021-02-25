text_begin:
  .byte $10, $12, $05, $13, $13, $20, $01, $0E, $19, $20, $0B, $05, $19, $20, $14, $0F, $20, $0C, $0F, $01, $04, $20, $07, $01, $0D, $05
  ; length = 26
text_newgame:
  .byte $10, $12, $05, $13, $13, $20, $0E, $20, $06, $0F, $12, $20, $0E, $05, $17, $20, $07, $01, $0D, $05
  ; length = 20
text_title:
  .byte $13, $09, $0D, $20, $03, $09, $14, $19, $20, $18, $31, $36
  ; length = 12
switchHexTable:
  .incbin "table.bin"
buildingsList:
  .res $800,$FF

.DEFINE list_lobyte .LOBYTE (buildingsList)
.DEFINE list_hibyte .HIBYTE (buildingsList)

test:
  .byte $00, $01, $01, $66, $66, $66, $66, $08, $66, $66, $66, $66, $00, $03, $00, $00 ; hospital
.DEFINE test_lobyte .LOBYTE (test)
.DEFINE test_hibyte .HIBYTE (test)


buildings:
  ;     fill x    y    character data                                    size          ;
  ;     0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F   ;
  .byte $00, $00, $00, $66, $66, $66, $66, $08, $66, $66, $66, $66, $00, $03, $00, $00 ; hospital
  .byte $00, $00, $00, $66, $40, $66, $42, $81, $42, $66, $40, $66, $00, $03, $00, $00 ; army base
  .byte $00, $00, $00, $E9, $DF, $F5, $F6, $00, $00, $00, $00, $00, $00, $02, $00, $00 ; house
  .byte $00, $00, $00, $24, $40, $24, $42, $02, $42, $24, $40, $24, $00, $03, $00, $00 ; bank
  .byte $00, $00, $00, $A4, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00 ; ATM

.DEFINE building_lobyte .LOBYTE (buildings)
.DEFINE building_hibyte .HIBYTE (buildings)
