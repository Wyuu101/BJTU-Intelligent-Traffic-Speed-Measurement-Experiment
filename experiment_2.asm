DATAS SEGMENT
   	L8255_PORTA    EQU   288H       ;A端口地址，数码管段选
   	L8255_PORTB    EQU   289H       ;B端口地址，数码管位选
   	L8255_PORTC    EQU   28AH       ;C端口地址，接拨码开关
   	L8255_PORTK    EQU   28BH       ;控制端口地址
   	L8254_TIM0    EQU   280H       ;计数器0，工作方式3，1000分频
   	L8254_TIM1    EQU   281H       ;计数器1，工作方式3,1000分频，输出1Hz
   	L8254_TIM2    EQU   282H       ;计数器2，工作方式2,硬件控制，计数  
   	L8254_TIMK    EQU   283H       ;控制寄存器端口地址
   	TIME       DB    0         ;时间
   	TIME_GE    DB    0         ;时间个位
   	TIME_SHI   DB    0         ;时间十位
   	LED        DB    3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H ;数码管段码
   	ASC        DB    30H,31H,32H,33H,34H,35H,36H,37H,38H,39H  ;保存数字1-9的ASCII码
   	FLAG	DB	0		;开关指示标志位，1为开始计数，0为计数结束
   	MSG DB 'SPEED:','$'
   	UNIT DB 'm/s',0DH,0AH,'$'	;速度的单位
DATAS ENDS

STACKS SEGMENT
   	DW 256 DUP(?)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
;----------------------定时器8254初始化设置----------------------
   	MOV DX,L8254_TIMK   ;向8254写控制字
   	MOV AL,36H          ;设计数器0工作方式3，输出1000Hz方波
   	OUT DX,AL
   	MOV AX,1000         ;写入循环计数初值1000
   	MOV DX,L8254_TIM0
   	OUT DX,AL           ;先写入低字节
   	MOV AL,AH
   	OUT DX,AL           ;后写入高字节
   
   	MOV DX,L8254_TIMK
   	MOV AL,76H          ;设计数器1工作方式3，输出1Hz方波
   	OUT DX,AL
   	MOV AX,1000         ; 写入循环计数初值1000
   	MOV DX,L8254_TIM1
   	OUT DX,AL           ;先写低字节
   	MOV AL,AH
   	OUT DX,AL           ;后写高字节
   
   	MOV DX,L8254_TIMK
   	MOV AL,0B4H         ;设计数器2工作方式2，循环计数，硬件控制
   	OUT DX,AL
   	MOV AX,0         	; 写入循环计数初值0
   	MOV DX,L8254_TIM2
   	OUT DX,AL          	;先写低字节
   	MOV AL,AH
   	OUT DX,AL           ;后写高字节

;----------------------------------------------------------------


;----------------------IO芯片8255初始化设置----------------------

  	MOV DX , L8255_PORTK
   	MOV AL , 81H
   	OUT DX , AL ;A方式0输出，B方式0输出，C7-C4输出，C0-C3输入
   
;----------------------------------------------------------------

START_MAIN:
   	CALL LED_DISPLAY_TIME0	;等待开关被拨至高电平1,同时在数码管循环显示上一次的计数值
LOOP_MAIN:
   	CALL READ_TIM2			;读计时器值并记录在TIME
   	CALL LED_DISPLAY_TIME1	;数码管显示计数值
   	CALL WAIT_KEY_0			;等待开关被拨至低电平0
   	MOV BL,0
   	MOV AL,FLAG
   	CMP BL,AL
   	JNZ LOOP_MAIN			;如果开关未变0，说明计时未结束，继续循环显示计数值
    CALL DOS_DISPLAY_SPEED	;在显示屏显示速度
    JMP START_MAIN			;回到开头等待下一次测距启动
    
    
    

WAIT_KEY_1 PROC				;等待开关置1子程序
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV BL,0
LOOP_KEY1:
	MOV DX,L8255_PORTC
	IN AL,DX				;循环检测C0电平
	AND AL,01H
	MOV BL,01H
	CMP BL,AL			
	JZ LOOP_KEY1			;如果是0，继续等待；如果是1，就返回主程序继续执行
	MOV FLAG,1				;FALG置1
	POP DX
	POP CX
	POP BX
	POP AX
	RET
WAIT_KEY_1 ENDP

;----------------------等带开关被拨0的子程序----------------------
WAIT_KEY_0 PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV DX,L8255_PORTC
	IN AL,DX				;循环检测C0电平
	AND AL,01H
	MOV BL,00H
	CMP BL,AL			
	JZ RETURN				;如果C0不是0，直接返回主程序；如果C0是0，FALG置0，标志测量结束
	MOV FLAG,0
	
RETURN:
	POP DX
	POP CX
	POP BX
	POP AX
	RET
WAIT_KEY_0 ENDP

;----------------------------------------------------------------


;---------------------读定时器计数值的子程序---------------------

READ_TIM2 PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

 	MOV AL,10000000B   		;锁存计数器2的计数值
  	MOV DX , L8254_TIMK
  	OUT DX , AL

  	MOV DX , L8254_TIM2
  	IN AL , DX         		;计数器2低字节
  	MOV AH , AL        		;暂存AH
  	IN AL , DX         		;计数器2高字节
  	XCHG  AH,AL         	;放入AX
  	
  	MOV BX,0
  	SUB BX,AX			
  	MOV TIME,BL 			;存入数据段中的变量（这里可以优化，提高可靠性）
  	
  	POP DX
  	POP CX
  	POP	BX
  	POP AX
  	RET
READ_TIM2 ENDP

;----------------------------------------------------------------


;------------------计数期间2位数码管显示子程序-------------------

LED_DISPLAY_TIME1 PROC		;在数码管显示2位数时间
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV AL,TIME				;被除数，时间
	MOV BL,10				;用于分离时间的个位和十位数字
	DIV BL				
	MOV TIME_GE,AH			;取余数放入个位
	MOV TIME_SHI,AL			;取商放入十位
	
	MOV BX,OFFSET LED		;取LED段码
	MOV AL,00000001B		;选通第个位数码管
	MOV DX,L8255_PORTB
	OUT DX,AL		
	MOV AH,0
	MOV AL,TIME_GE
	MOV SI,AX	
	MOV AL,[BX+SI]			;把个位数转化为段码显示在数码管上
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;延时20ms
	
	MOV AL,00000010B		;选通第十位数码管
	MOV DX,L8255_PORTB
	OUT DX,AL	
	MOV AH,00H
	MOV AL,TIME_SHI		
	MOV AL,[BX+SI]			;把个位数转化为段码显示在数码管上
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;延时20ms
	
	POP DX
  	POP CX
  	POP	BX
  	POP AX
	RET
LED_DISPLAY_TIME1 ENDP

;----------------------------------------------------------------

;----------------计数停止期间2位数码管显示子程序-----------------
LED_DISPLAY_TIME0 PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

LOOP_KEY0:
	MOV BX,OFFSET LED		;取LED段码
	MOV AL,00000001B		;选通第个位数码管
	MOV DX,L8255_PORTB
	OUT DX,AL			
	MOV AH,00H
	MOV AL,TIME_GE
	MOV SI,AX
	MOV AL,[BX+SI]			;把个位数转化为段码显示在数码管上
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;延时20ms
	
	MOV AL,00000010B		;选通第十位数码管
	MOV DX,L8255_PORTB
	OUT DX,AL	
	MOV AH,00H
	MOV AL,TIME_SHI
	MOV SI,AX		
	MOV AL,[BX+SI]			;把个位数转化为段码显示在数码管上
	MOV DX,L8255_PORTA
	OUT DX,AL
	
	CALL DELAY 				;延时20ms


	MOV DX,L8255_PORTC
	IN AL,DX				;循环检测C0电平
	AND AL,01H
	MOV BL,01H
	CMP BL,AL			
	JNZ LOOP_KEY0			;如果是0，继续等待；如果是1，FLAG置1并返回主程序继续执行
	MOV FLAG,1				;FALG置1

	POP DX
  	POP CX
  	POP	BX
  	POP AX
	RET
LED_DISPLAY_TIME0 ENDP

;----------------------------------------------------------------


;---------------------DOS调试显示速度子程序----------------------

DOS_DISPLAY_SPEED PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI

	MOV DX,OFFSET MSG		;显示“SPEED:”
	MOV AH,09H			
	INT 21
	
	MOV AX,100				;路程，被除数
	MOV BL,TIME
	DIV BL					;时间，除数
	MOV DH,AH
	MOV BX,OFFSET ASC		;取ASCII码
	MOV AH,00H			
	MOV SI,AX			
	MOV DL,[BX+SI]			;显示速度的十位
	MOV AH,02H
	INT 20
	MOV AH,00H		
	MOV AL,DH
	MOV SI,AX
	MOV DL,[BX+SI]			;显示速度的个位
	MOV AH,02H
	INT 21
	
	MOV DX,OFFSET UNIT		;显示速度的单位“m/s”
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

;---------------------------延时子程序---------------------------

DELAY PROC					;延时20ms
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



























