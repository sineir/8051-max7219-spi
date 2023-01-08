DATA_PIN	BIT	P2.2
LOAD_PIN	BIT	P2.3
CLOCK_PIN	BIT	P2.4
BUFF_U		EQU	08H
LED		BIT	P1.0
ORG	0x00
;==============================================
MAIN:
	MOV	P2,#0
	SETB	LOAD_PIN
	CLR	CLOCK_PIN
	CLR	DATA_PIN
	ACALL	MAX7219_INIT
MAIN2:
	SETB	LED
	ACALL	DELAY;	
	CLR	LED
	ACALL	DELAY;	

	SJMP	MAIN2
	;SJMP	$	;self loop
;-----------------------------------------------
MAX7219_Init:
	MOV	R0,#0x0b
	MOV	R1,#7
	ACALL	MAX7219_WRITE
	MOV	R0,#9
	MOV	R1,#0
	ACALL	MAX7219_WRITE
	ACALL	MAX7219_SHUTDOWNSTOP
	ACALL	MAX7219_DISPLAYTESTSTOP
	ACALL	MAX7219_CLEAR
	ACALL	MAX7219_SETBRIGHTNESS

	;teste envia 1234 (dg:3,dg:2,dg:1,dg:0)

	MOV	R1,#0x70 ; 7
	MOV	R0,#0 ; digito 0
 	ACALL	MAX7219_WRITE

	MOV	R1,#0x33 ; 4
	MOV	R0,#1 ; digito 0
 	ACALL	MAX7219_WRITE

	MOV	R1,#0x77 ;A
	MOV	R0,#2 ; digito 0
 	ACALL	MAX7219_WRITE

	MOV	R1,#0x79 ;3
	MOV	R0,#3 ; digito 0
 	ACALL	MAX7219_WRITE


	;SJMP	$	;trava loop infinito

	RET
;-----------------------------------------------
MAX7219_ShutdownStart:
;#define REG_SHUTDOWN      0x0c
;MAX7219_Write(REG_SHUTDOWN, 0);
	MOV	R0,#0x0c
	MOV	R1,#0
	RET
;-----------------------------------------------
 MAX7219_ShutdownStop:
 	MOV	R0,#0x0c
 	MOV	R1,#1
 	ACALL	MAX7219_WRITE
 	RET
;-----------------------------------------------
MAX7219_DisplayTestStart:
;#define REG_DISPLAY_TEST  0x0f
;MAX7219_Write(REG_DISPLAY_TEST, 1);
 	MOV	R0,#0x0f
 	MOV	R1,#1
 	ACALL	MAX7219_WRITE
	RET
;-----------------------------------------------
MAX7219_DisplayTestStop:
 	MOV	R0,#0x0f
 	MOV	R1,#0
 	ACALL	MAX7219_WRITE
	RET
;-----------------------------------------------
MAX7219_SetBrightness:
;REG_INTENSITY     0x0a
;INTENSITY_MAX     0x0f

;brightness &= 0x0f;                                // mask off extra bits
	MOV	R3,0x0f
	MOV	A,0x0a
	ANL	A,R3
;MAX7219_Write(REG_INTENSITY, brightness);           // set brightness
	MOV	R0,#0x05
	MOV	R1,A
	ACALL	MAX7219_WRITE
	RET
;-----------------------------------------------
MAX7219_Clear:
;char i;
 ; for (i=0; i < 8; i++)
  ;  MAX7219_Write(i, 0x00);

  	MOV	R1,#0
  	MOV	A,#0
 FOR1:
 	MOV	R0,A
  	ACALL	MAX7219_WRITE
  	INC	A
  	CJNE	A,#8,FOR1
	RET
;-----------------------------------------------
MAX7219_DisplayChar:
;void MAX7219_DisplayChar (char digit, char character)
;char digit = 0-7
;char character = 0 - 9, 10(AH):apagado
;  MAX7219_Write(digit, MAX7219_LookupCode(character));
	
	RET

;----------------SUB ROTINAS--------------------
;-----------------------------------------------
MAX7219_Write:
	CLR	LOAD_PIN
	MOV	A,R0
	ACALL	MAX7219_SENDBYTE
	MOV	A,R1
	ACALL	MAX7219_SENDBYTE
	SETB	LOAD_PIN
	RET
;-----------------------------------------------
;PASSAR ARGUMENTO EM 'ACC':A
MAX7219_SENDBYTE:
	MOV	B,#8
SDL1:
	RLC	A
	NOP
	CLR	CLOCK_PIN
	NOP
	MOV	DATA_PIN,C
	NOP
	SETB	CLOCK_PIN
	NOP

	DJNZ	B,SDL1
	
	RET
;-----------------------------------------------
MAX7219_LookupCode:

	RET

;-----------------------------------------------
;---------PROTOTYPES
;#define REG_DECODE        0x09                        // "decode mode" register
;#define REG_INTENSITY     0x0a                        // "intensity" register
;#define REG_SCAN_LIMIT    0x0b                        // "scan limit" register
;#define REG_SHUTDOWN      0x0c                        // "shutdown" register
;#define REG_DISPLAY_TEST  0x0f                        // "display test" register

;#define INTENSITY_MIN     0x00                        // minimum display intensity
;#define INTENSITY_MAX     0x0f                        // maximum display intensity

DELAY:
	;RET
	MOV	R5,#255
DL1:
	MOV	R6,#4
DL2:
	MOV	R7,#255
	DJNZ	R7,$
	DJNZ	R6,DL2
	DJNZ	R5,DL1
	RET
;==============================================
ORG 500H
		; 0.....9, 10(AH)00H:cleared
		DB 07EH, 030H, 06DH, 79H, 33H, 05BH, 05FH, 070H, 07FH,07BH,0H,'%'
END
