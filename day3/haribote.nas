org     0xc400

;draw on screen
mov     al,0x13
mov     ah,0x00
int     0x10

fin:
    HLT
    JMP     fin
