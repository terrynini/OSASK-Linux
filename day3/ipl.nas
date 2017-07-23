        ;read 10 cylinders
        CYLS    EQU     10
        
        ORG     0x7c00          
        JMP     entry

        ;set fat12 
        DB      0x90
        DB      "HARIBOTE"       
        DW      512              
        DB      1                
        DW      1                
        DB      2               
        DW      224         
        DW      2880    
        DB      0xf0             
        DW      9                
        DW      18          
        DW      2                
        DD      0                
        DD      2880        
        DB      0,0,0x29         
        DD      0xffffffff  
        DB      "HARIBOTEOS "
        DB      "FAT12   "       

entry:
        ;init registers
        MOV     AX,0            
        MOV     SS,AX
        MOV     SP,0x7c00
        MOV     DS,AX

        MOV     AX,0x0820
        MOV     ES,AX       ;point to 0x8200
        MOV     CH,0        ;cylinder    
        MOV     DH,0        ;head   
        MOV     CL,2        ;sector
readloop:
        MOV     SI,0        ;how many times we have tried to read

retry:
;read from disk(BOIS interrupt call)
;AL:Sectors To Read Count CH:Cylinder CL:Sector 
;DH:Head DL:Drive ES:BX:Buffer Address Pointer     
        MOV     AH,0x02         
        MOV     AL,1             
        MOV     BX,0
        MOV     DL,0x00    
        INT     0x13       
        JNC     next    ;read next sector if there is no error
        ADD     SI,1
        CMP     SI,5
        JAE     error   ;failed 5 times
        MOV     AH,0x00 ;reset
        MOV     DL,0x00
        INT     0x13
        JMP     retry

next:
        MOV     AX,ES
        add     ax,0x0020
        mov     es,ax
        add     cl,1
        cmp     cl,18
        jbe     readloop
        mov     cl,1
        add     dh,1
        cmp     dh,2
        jb      readloop
        mov     dh,0
        add     ch,1
        cmp     ch,CYLS
        jb      readloop
        jmp     0xc400
fin:
        HLT                     
        JMP     fin             

error:
        MOV     SI,msg
putloop:
        MOV     AL,[SI]
        ADD     SI,1            
        CMP     AL,0
        JE      fin
        MOV     AH,0x0e         
        MOV     BX,15           
        INT     0x10            
        JMP     putloop
msg:
        DB      0x0a, 0x0a      
        DB      "load error"
        DB      0x0a            
        DB      0

        times   510-($-$$) db 0        
        DB      0x55, 0xaa

