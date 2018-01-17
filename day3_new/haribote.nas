BOTPAK	EQU	0x00280000
DSKCAC	EQU	0x00100000
DSKCAC0	EQU	0x00008000

; Boot information
CYLS    equ     0x0ff0
LEDS    equ     0x0ff1
VMODE   equ     0x0ff2  ;digits of color, information about numbers of color
SCRNX   equ     0x0ff4  ;screen x
SCRNY   equ     0x0ff6  ;screen y
VRAM    equ     0x0ff8  ;begin address of vedio RAM

    ;org     0xc400
_start:
    ;draw on screen
    mov     al,0x13
    mov     ah,0x00
    int     0x10
    mov     byte [VMODE], 8     ;record
    mov     word [SCRNX], 320
    mov     word [SCRNY], 200
    mov     dword [VRAM], 0x000a0000
;use BIOS to get LED (indicator light) on keyboard , 
    mov     ah, 0x2
    int     0x16        ;keyboard BIOS
    mov     [LEDS], al

;new thing , not explain yet
		MOV		AL,0xff
		OUT		0x21,AL
		NOP						
		OUT		0xa1,AL

		CLI						

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			
		OUT		0x60,AL
		CALL	waitkbdout



[BITS 32] 
		LGDT	[GDTR0]			
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	
		OR		EAX,0x00000001	
		MOV		CR0,EAX
		JMP		pipelineflush

pipelineflush:
		MOV		AX,1*8			
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

		MOV		ESI,bootpack	
		MOV		EDI,BOTPAK		
		MOV		ECX,512*1024/4
		CALL	memcpy





		MOV		ESI,0x7c00		
		MOV		EDI,DSKCAC		
		MOV		ECX,512/4
		CALL	memcpy



		MOV		ESI,DSKCAC0+512	
		MOV		EDI,DSKCAC+512	
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	
		SUB		ECX,512/4		
		CALL	memcpy






		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			
		SHR		ECX,2			
		JZ		skip			
		MOV		ESI,[EBX+20]	
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			
		RET


		ALIGNB	16
GDT0:
		RESB	8				
		DW		0xffff,0x0000,0x9200,0x00cf	
		DW		0xffff,0x0000,0x9a28,0x0047	

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:

