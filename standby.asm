DATAS SEGMENT
    L8255_A    EQU   288H       ;A端口地址,数码管数据
    L8255_B    EQU   289H       ;B端口地址，B0,B1 位选数码管
    L8255_C    EQU   28AH       ;C端口地址，C0读拨码开关
    L8255_K    EQU   28BH       ;寄存器端口地址
    
    L8254_0    EQU   280H       ;计数器0，工作方式3，1000分频
    L8254_1    EQU   281H       ;计数器1，工作方式3,1000分频，输出1Hz
    L8254_2    EQU   282H       ;计数器2，工作方式2,硬件控制，计数 
    L8254_K    EQU   283H       ;寄存器端口地址
    FLAG       DB    0          ;拨码开关状怿
    LED        DB    3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H ;段码
    ASC        DB 30H,31H,32H,33H,34H,35H,36H,37H,38H,39H  ;保存数字1-9的ASCII码
    TIME       DB    0         ;时间
    TIME_GE    DB    0         ;时间个位
    TIME_SHI   DB    0         ;时间十位
    SPEED   DB    0         ;速度    
    SPEED_GE    DB    0         ;速度个位
    SPEED_SHI   DB    0         ;速度十位
    DISTANCE DB 100 ;路程
    buf        db    100     
    MSG1 DB 0DH,0AH,"THE SPEED IS: $"
    NUM       DW    0       ;计数结束的值，16位  
DATAS ENDS
STACKS SEGMENT STACK 
PP       DW 256 DUP(?)
STACKS ENDS
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
;***********并行IO8255初始化
    MOV DX , L8255_K
    MOV AL , 81H 
    OUT DX , AL ;A方式0输出，B方式0输出，C7-C4输出，C0-C3输入
        
;***********定时器8254初始化
    MOV DX,L8254_K        ;向8254写控制字
    MOV AL,36H          ;使计数器0为工作方式3
    OUT DX,AL
    MOV AX,1000         ;写入循环计数初值1000
    MOV DX,L8254_0
    OUT DX,AL           ;先写入低字节
    MOV AL,AH
    OUT DX,AL           ;后写入高字节
    MOV DX,L8254_K
    MOV AL,76H          ;设计数器1工作方式3，输出1hz方波
    OUT DX,AL
    MOV AX,1000         ; 写入循环计数初值1000
    MOV DX,L8254_1
    OUT DX,AL           ;先写低字节
    MOV AL,AH
    OUT DX,AL           ;后写高字节
    MOV DX,L8254_K
    MOV AL,0B4H          ;设计数器2工作方式2，循环计数，硬件控制
    OUT DX,AL
    MOV AX,0         ; 写入循环计数初值0
    MOV DX,L8254_2
    OUT DX,AL           ;先写低字节
    MOV AL,AH
    OUT DX,AL           ;后写高字节
    MOV FLAG , 0
    MOV TIME , 0
    
;***********主循玿   
START_MAIN:
    CALL CLE
    CALL SHOW_2            ;显示时间
    CALL SHOW_DOS   
    CALL KEY_SCAN           ;按件扫描
    CALL TIME_DATAUP             ;时间更新

NEXT_MAIN:
    JMP START_MAIN    
    
;*********返回DOS    
    MOV AH,4CH
    INT 21H

CLE PROC
PUSH AX
PUSH BX
PUSH DX

MOV AX,0

POP DX
POP BX
POP AX
RET
CLE ENDP

;*********两位数码管显示子程序    
SHOW_2   PROC

    push AX
    push BX
    push DX
    CMP FLAG ,0
    JZ SHOWSPEED

    MOV BL ,10   ;将10放入寄存器BX，用来分离个位数
    MOV AL , TIME
    MOV AH , 0
    DIV BL     ;AL/BL,商放入AL，余数放入AH
    MOV TIME_GE , AH
    MOV AH , 0 
    DIV BL
    MOV TIME_SHI ,AH
    MOV AH , 0 
    
    LEA BX , LED ;将数码管码表的首地址放入BX
    MOV AL , TIME_GE
    XLAT       ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV TIME_GE ,AL
     LEA BX , LED ;将数码管码表的首地址放入BX
    MOV AL , TIME_SHI
    XLAT       ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV TIME_SHI ,AL
    ;个位
    MOV      DX,L8255_A    ;自8255A的口输出
    MOV      AL , 00000000B   ;数码管灭
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV      AL , 00000001B   ;右侧数码管亮
    OUT      DX,AL
    MOV      DX,L8255_A     ;自8255A的口输出
    MOV      AL,TIME_GE
    OUT      DX,AL   
    
    CALL DELAY1  ;延时

    ;十位
    MOV      DX,L8255_A             ;自8255A的口输出
    MOV      AL , 00000000B   ;数码管灭
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV       AL , 00000010B   ;左侧数码管亮
    OUT      DX,AL
    
    MOV      DX,L8255_A   ;自8255A的口输出
    MOV      AL ,TIME_SHI
    OUT     DX,AL  
     

    CALL DELAY1  ;延时
    JMP SHOW_2END
SHOWSPEED:
    MOV BL ,10   ;将10放入寄存器BX，用来分离个位数
    MOV AL , SPEED
    MOV AH , 0
    DIV BL     ;AL/BL,商放入AL，余数放入AH
    MOV SPEED_GE , AH
    MOV AH , 0 
    DIV BL
    MOV SPEED_SHI ,AH
    MOV AH , 0 
    
    LEA BX , LED ;将数码管码表的首地址放入BX
    MOV AL , SPEED_GE
    XLAT       ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV SPEED_GE ,AL
     LEA BX , LED ;将数码管码表的首地址放入BX
    MOV AL , SPEED_SHI
    XLAT       ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV SPEED_SHI ,AL
    ;个位
    MOV      DX,L8255_A    ;自8255A的口输出
    MOV      AL , 00000000B   ;数码管灭
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV      AL , 00000001B   ;右侧数码管亮
    OUT      DX,AL
    MOV      DX,L8255_A    ;自8255A的口输出
    MOV      AL,SPEED_GE
    OUT      DX,AL   
    
    CALL DELAY1  ;延时

    ;十位
    MOV      DX,L8255_A              ;自8255A的口输出
    MOV      AL , 00000000B   ;数码管灭
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV       AL , 00000010B   ;左侧数码管亮
    OUT      DX,AL
    
    MOV      DX,L8255_A   ;自8255A的口输出
    MOV      AL ,SPEED_SHI
    OUT     DX,AL  
     
    CALL DELAY1  ;延时   
       
    LEA DX,MSG1
    MOV AH,9
    INT 21H
    
    MOV AL ,SPEED
    MOV BUF, AL
    
    MOV BL ,10   ;将10放入寄存器BX，用来分离个位数
    MOV AL , SPEED
    MOV AH , 0
    DIV BL     ;AL/BL,商放入AL，余数放入AH
    MOV SPEED_GE , AH
    MOV AH , 0 
    DIV BL
    MOV SPEED_SHI ,AH
    MOV AH , 0 
    
    MOV AL , SPEED_SHI
    ;ADD AL,30H
    LEA BX , ASC ;将数码管码表的首地址放入BX
    XLAT       ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV DL,AL  ;用dos02号功能，输出字符
    MOV AH , 02H
    INT 21H
    
    MOV AL , SPEED_GE
    ;ADD AL,30H
    LEA BX , ASC ;将数码管码表的首地址放入BX
    XLAT         ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV DL,AL    ;用dos02号功能，输出字符
    MOV AH , 02H
    INT 21H    
    
SHOW_2END:    
    pop DX
    pop BX
    pop AX
    RET
SHOW_2      ENDP


    
;*********一位数码管显示子程序   
SHOW_1             PROC

    push AX
    push BX
    push DX
    
    CMP TIME ,0FH
    JA SHOW_1_END

    MOV      DX,L8255_B
    MOV      AL , 00000001B   ;右侧数码管亮
    OUT      DX,AL 
    
    LEA BX , LED ;将数码管码表的首地址放入BX
    MOV AL , TIME
    XLAT       ;查表指令，将DS：[BX+AL]的内容送到AL中
    ;输出   
    MOV      DX,L8255_A    ;8255A的口输出
    OUT      DX,AL    
SHOW_1_END:    
    pop DX
    pop BX
    pop AX
    RET
SHOW_1           ENDP

;*********DOS显示子程序
SHOW_DOS            PROC

    push AX
    push BX
    push DX
    
    CMP FLAG ,0
    JZ SHOW_DOS_END
    
    MOV AL ,TIME
    cmp buf , AL
    jz SHOW_DOS_END
    
    MOV AL ,TIME
    MOV BUF, AL
    
    MOV BL ,10   ;将10放入寄存器BX，用来分离个位数
    MOV AL , TIME
    MOV AH , 0
    DIV BL     ;AL/BL,商放入AL，余数放入AH
    MOV TIME_GE , AH
    MOV AH , 0 
    DIV BL
    MOV TIME_SHI ,AH
    MOV AH , 0 
    
    MOV AL , TIME_SHI
    ;ADD AL,30H
    LEA BX , ASC ;将数码管码表的首地址放入BX
    XLAT      ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV DL,AL  ;用dos02号功能，输出字符
    MOV AH , 02H
    INT 21H
    
    MOV AL , TIME_GE
    ;ADD AL,30H
    LEA BX , ASC ;将数码管码表的首地址放入BX
    XLAT         ;查表指令，将DS：[BX+AL]的内容送到AL中
    MOV DL,AL    ;用dos02号功能，输出字符
    MOV AH , 02H
    INT 21H
    
    MOV DL,','  ;用dos02号功能，输出字符
    MOV AH , 02H
    INT 21H

 SHOW_DOS_END:    
    pop DX
    pop BX
    pop AX
    RET
SHOW_DOS           ENDP


;*********按键查询显示子程序,C0读拨码开关

KEY_SCAN       PROC
    push ax
    push bx
    push dx

    MOV DX , L8255_C
    IN  AL  , DX
    AND AL , 00000001B
    CMP AL , 1   ;高电平计数
    JZ K1
    ;否则丿
    MOV FLAG , 0
    JMP KEY_SCAN_END
K1:
    MOV FLAG , 1 
KEY_SCAN_END:
    MOV AL,100
    MOV AH,0
    CMP TIME,0
    JZ KEY_SCAN_END2
    DIV TIME
    MOV SPEED,AL
    
KEY_SCAN_END2:    
    pop dx
    pop bx
    pop ax
    RET
KEY_SCAN        ENDP

;*********时间更新子程序子程序

TIME_DATAUP            PROC

    push AX
    push BX
    push DX
    
    CMP FLAG ,1
    JZ T1
T0:   

   JMP TIME_DATAUP_END
   
T1:
   MOV AL,10000000B  ;锁存计数器2的值
   MOV DX , L8254_K
   OUT DX , AL
   MOV DX , L8254_2
   IN AL , DX         ;计数器2低字节
   MOV AH , AL        ;暂存AH
   IN AL , DX          ;计数器2高字节
   XCHG  AH,AL          ;放入AX
   MOV NUM , AX      ;放计数末值
   MOV BX , 0
   SUB BX ,AX   ;满量程减现在计数，得到时间（秒）
   
   MOV TIME , BL
   
   
TIME_DATAUP_END:    
    pop DX
    pop BX
    pop AX
    RET
TIME_DATAUP            ENDP


;*********延时子程序
DELAY1           PROC
;数码管延时
                push ax
                push cx
                push dx
                MOV CX, 0FFfh
 x1:           loop   x1
                pop dx
                pop cx
                pop ax
                RET
DELAY1            ENDP

CODES ENDS
    END START