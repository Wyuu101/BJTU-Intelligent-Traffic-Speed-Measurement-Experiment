DATAS SEGMENT
   	L8255_PORTA    EQU   288H       ;A�˿ڵ�ַ������ܶ�ѡ
   	L8255_PORTB    EQU   289H       ;B�˿ڵ�ַ�������λѡ
   	L8255_PORTC    EQU   28AH       ;C�˿ڵ�ַ���Ӳ��뿪��
   	L8255_PORTK    EQU   28BH       ;���ƶ˿ڵ�ַ
   	L8254_TIM0    EQU   280H       ;������0��������ʽ3��1000��Ƶ
   	L8254_TIM1    EQU   281H       ;������1��������ʽ3,1000��Ƶ�����1Hz
   	L8254_TIM2    EQU   282H       ;������2��������ʽ2,Ӳ�����ƣ�����  
   	L8254_TIMK    EQU   283H       ;���ƼĴ����˿ڵ�ַ
   	TIME       DB    0         ;ʱ��
   	TIME_GE    DB    0         ;ʱ���λ
   	TIME_SHI   DB    0         ;ʱ��ʮλ
   	LED        DB    3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H ;����ܶ���
   	ASC        DB    30H,31H,32H,33H,34H,35H,36H,37H,38H,39H  ;��������1-9��ASCII��
   	FLAG	DB	0		;����ָʾ��־λ��1Ϊ��ʼ������0Ϊ��������
   	MSG DB 'SPEED:','$'
   	UNIT DB 'm/s',0DH,0AH,'$'	;�ٶȵĵ�λ
DATAS ENDS

STACKS SEGMENT
   	DW 256 DUP(?)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
;----------------------��ʱ��8254��ʼ������----------------------
   	MOV DX,L8254_TIMK   ;��8254д������
   	MOV AL,36H          ;�������0������ʽ3�����1000Hz����
   	OUT DX,AL
   	MOV AX,1000         ;д��ѭ��������ֵ1000
   	MOV DX,L8254_TIM0
   	OUT DX,AL           ;��д����ֽ�
   	MOV AL,AH
   	OUT DX,AL           ;��д����ֽ�
   
   	MOV DX,L8254_TIMK
   	MOV AL,76H          ;�������1������ʽ3�����1Hz����
   	OUT DX,AL
   	MOV AX,1000         ; д��ѭ��������ֵ1000
   	MOV DX,L8254_TIM1
   	OUT DX,AL           ;��д���ֽ�
   	MOV AL,AH
   	OUT DX,AL           ;��д���ֽ�
   
   	MOV DX,L8254_TIMK
   	MOV AL,0B4H         ;�������2������ʽ2��ѭ��������Ӳ������
   	OUT DX,AL
   	MOV AX,0         	; д��ѭ��������ֵ0
   	MOV DX,L8254_TIM2
   	OUT DX,AL          	;��д���ֽ�
   	MOV AL,AH
   	OUT DX,AL           ;��д���ֽ�

;----------------------------------------------------------------


;----------------------IOоƬ8255��ʼ������----------------------

  	MOV DX , L8255_PORTK
   	MOV AL , 81H
   	OUT DX , AL ;A��ʽ0�����B��ʽ0�����C7-C4�����C0-C3����
   
;----------------------------------------------------------------

START_MAIN:
   	CALL LED_DISPLAY_TIME0	;�ȴ����ر������ߵ�ƽ1,ͬʱ�������ѭ����ʾ��һ�εļ���ֵ
LOOP_MAIN:
   	CALL READ_TIM2			;����ʱ��ֵ����¼��TIME
   	CALL LED_DISPLAY_TIME1	;�������ʾ����ֵ
   	CALL WAIT_KEY_0			;�ȴ����ر������͵�ƽ0
   	MOV BL,0
   	MOV AL,FLAG
   	CMP BL,AL
   	JNZ LOOP_MAIN			;�������δ��0��˵����ʱδ����������ѭ����ʾ����ֵ
    CALL DOS_DISPLAY_SPEED	;����ʾ����ʾ�ٶ�
    JMP START_MAIN			;�ص���ͷ�ȴ���һ�β������
    
    
    

WAIT_KEY_1 PROC				;�ȴ�������1�ӳ���
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV BL,0
LOOP_KEY1:
	MOV DX,L8255_PORTC
	IN AL,DX				;ѭ�����C0��ƽ
	AND AL,01H
	MOV BL,01H
	CMP BL,AL			
	JZ LOOP_KEY1			;�����0�������ȴ��������1���ͷ������������ִ��
	MOV FLAG,1				;FALG��1
	POP DX
	POP CX
	POP BX
	POP AX
	RET
WAIT_KEY_1 ENDP

;----------------------�ȴ����ر���0���ӳ���----------------------
WAIT_KEY_0 PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV DX,L8255_PORTC
	IN AL,DX				;ѭ�����C0��ƽ
	AND AL,01H
	MOV BL,00H
	CMP BL,AL			
	JZ RETURN				;���C0����0��ֱ�ӷ������������C0��0��FALG��0����־��������
	MOV FLAG,0
	
RETURN:
	POP DX
	POP CX
	POP BX
	POP AX
	RET
WAIT_KEY_0 ENDP

;----------------------------------------------------------------


;---------------------����ʱ������ֵ���ӳ���---------------------

READ_TIM2 PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

 	MOV AL,10000000B   		;���������2�ļ���ֵ
  	MOV DX , L8254_TIMK
  	OUT DX , AL

  	MOV DX , L8254_TIM2
  	IN AL , DX         		;������2���ֽ�
  	MOV AH , AL        		;�ݴ�AH
  	IN AL , DX         		;������2���ֽ�
  	XCHG  AH,AL         	;����AX
  	
  	MOV BX,0
  	SUB BX,AX			
  	MOV TIME,BL 			;�������ݶ��еı�������������Ż�����߿ɿ��ԣ�
  	
  	POP DX
  	POP CX
  	POP	BX
  	POP AX
  	RET
READ_TIM2 ENDP

;----------------------------------------------------------------


;------------------�����ڼ�2λ�������ʾ�ӳ���-------------------

LED_DISPLAY_TIME1 PROC		;���������ʾ2λ��ʱ��
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV AL,TIME				;��������ʱ��
	MOV BL,10				;���ڷ���ʱ��ĸ�λ��ʮλ����
	DIV BL				
	MOV TIME_GE,AH			;ȡ���������λ
	MOV TIME_SHI,AL			;ȡ�̷���ʮλ
	
	MOV BX,OFFSET LED		;ȡLED����
	MOV AL,00000001B		;ѡͨ�ڸ�λ�����
	MOV DX,L8255_PORTB
	OUT DX,AL		
	MOV AH,0
	MOV AL,TIME_GE
	MOV SI,AX	
	MOV AL,[BX+SI]			;�Ѹ�λ��ת��Ϊ������ʾ���������
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;��ʱ20ms
	
	MOV AL,00000010B		;ѡͨ��ʮλ�����
	MOV DX,L8255_PORTB
	OUT DX,AL	
	MOV AH,00H
	MOV AL,TIME_SHI		
	MOV AL,[BX+SI]			;�Ѹ�λ��ת��Ϊ������ʾ���������
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;��ʱ20ms
	
	POP DX
  	POP CX
  	POP	BX
  	POP AX
	RET
LED_DISPLAY_TIME1 ENDP

;----------------------------------------------------------------

;----------------����ֹͣ�ڼ�2λ�������ʾ�ӳ���-----------------
LED_DISPLAY_TIME0 PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

LOOP_KEY0:
	MOV BX,OFFSET LED		;ȡLED����
	MOV AL,00000001B		;ѡͨ�ڸ�λ�����
	MOV DX,L8255_PORTB
	OUT DX,AL			
	MOV AH,00H
	MOV AL,TIME_GE
	MOV SI,AX
	MOV AL,[BX+SI]			;�Ѹ�λ��ת��Ϊ������ʾ���������
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;��ʱ20ms
	
	MOV AL,00000010B		;ѡͨ��ʮλ�����
	MOV DX,L8255_PORTB
	OUT DX,AL	
	MOV AH,00H
	MOV AL,TIME_SHI
	MOV SI,AX		
	MOV AL,[BX+SI]			;�Ѹ�λ��ת��Ϊ������ʾ���������
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;��ʱ20ms


	MOV DX,L8255_PORTC
	IN AL,DX				;ѭ�����C0��ƽ
	AND AL,01H
	MOV BL,01H
	CMP BL,AL			
	JNZ LOOP_KEY0			;�����0�������ȴ��������1��FLAG��1���������������ִ��
	MOV FLAG,1				;FALG��1

	POP DX
  	POP CX
  	POP	BX
  	POP AX
	RET
LED_DISPLAY_TIME0 ENDP

;----------------------------------------------------------------


;---------------------DOS������ʾ�ٶ��ӳ���----------------------

DOS_DISPLAY_SPEED PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI

	MOV DX,OFFSET MSG		;��ʾ��SPEED:��
	MOV AH,09H			
	INT 21
	
	MOV AX,100				;·�̣�������
	MOV BL,TIME
	DIV BL					;ʱ�䣬����
	MOV DH,AH
	MOV BX,OFFSET ASC		;ȡASCII��
	MOV AH,00H			
	MOV SI,AX			
	MOV DL,[BX+SI]			;��ʾ�ٶȵ�ʮλ
	MOV AH,02H
	INT 20
	MOV AH,00H		
	MOV AL,DH
	MOV SI,AX
	MOV DL,[BX+SI]			;��ʾ�ٶȵĸ�λ
	MOV AH,02H
	INT 21
	
	MOV DX,OFFSET UNIT		;��ʾ�ٶȵĵ�λ��m/s��
	MOV	AH,09H
	INT 21
	
	
	POP SI
	POP DX
  	POP CX
  	POP	BX
  	POP AX
	RET
DOS_DISPLAY_SPEED ENDP

;----------------------------------------------------------------

;---------------------------��ʱ�ӳ���---------------------------

DELAY PROC					;��ʱ20ms
	PUSH CX

	MOV CX,20000
DELAY_LOOP:
	LOOP DELAY_LOOP
	
	POP CX	
	RET
DELAY ENDP

;----------------------------------------------------------------
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START



























