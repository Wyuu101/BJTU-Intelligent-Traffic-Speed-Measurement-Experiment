DATAS SEGMENT
    L8255_A    EQU   288H       ;A�˿ڵ�ַ,���������
    L8255_B    EQU   289H       ;B�˿ڵ�ַ��B0,B1 λѡ�����
    L8255_C    EQU   28AH       ;C�˿ڵ�ַ��C0�����뿪��
    L8255_K    EQU   28BH       ;�Ĵ����˿ڵ�ַ
    
    L8254_0    EQU   280H       ;������0��������ʽ3��1000��Ƶ
    L8254_1    EQU   281H       ;������1��������ʽ3,1000��Ƶ�����1Hz
    L8254_2    EQU   282H       ;������2��������ʽ2,Ӳ�����ƣ����� 
    L8254_K    EQU   283H       ;�Ĵ����˿ڵ�ַ
    FLAG       DB    0          ;���뿪��״��
    LED        DB    3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H ;����
    ASC        DB 30H,31H,32H,33H,34H,35H,36H,37H,38H,39H  ;��������1-9��ASCII��
    TIME       DB    0         ;ʱ��
    TIME_GE    DB    0         ;ʱ���λ
    TIME_SHI   DB    0         ;ʱ��ʮλ
    SPEED   DB    0         ;�ٶ�    
    SPEED_GE    DB    0         ;�ٶȸ�λ
    SPEED_SHI   DB    0         ;�ٶ�ʮλ
    DISTANCE DB 100 ;·��
    buf        db    100     
    MSG1 DB 0DH,0AH,"THE SPEED IS: $"
    NUM       DW    0       ;����������ֵ��16λ  
DATAS ENDS
STACKS SEGMENT STACK 
PP       DW 256 DUP(?)
STACKS ENDS
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
;***********����IO8255��ʼ��
    MOV DX , L8255_K
    MOV AL , 81H 
    OUT DX , AL ;A��ʽ0�����B��ʽ0�����C7-C4�����C0-C3����
        
;***********��ʱ��8254��ʼ��
    MOV DX,L8254_K        ;��8254д������
    MOV AL,36H          ;ʹ������0Ϊ������ʽ3
    OUT DX,AL
    MOV AX,1000         ;д��ѭ��������ֵ1000
    MOV DX,L8254_0
    OUT DX,AL           ;��д����ֽ�
    MOV AL,AH
    OUT DX,AL           ;��д����ֽ�
    MOV DX,L8254_K
    MOV AL,76H          ;�������1������ʽ3�����1hz����
    OUT DX,AL
    MOV AX,1000         ; д��ѭ��������ֵ1000
    MOV DX,L8254_1
    OUT DX,AL           ;��д���ֽ�
    MOV AL,AH
    OUT DX,AL           ;��д���ֽ�
    MOV DX,L8254_K
    MOV AL,0B4H          ;�������2������ʽ2��ѭ��������Ӳ������
    OUT DX,AL
    MOV AX,0         ; д��ѭ��������ֵ0
    MOV DX,L8254_2
    OUT DX,AL           ;��д���ֽ�
    MOV AL,AH
    OUT DX,AL           ;��д���ֽ�
    MOV FLAG , 0
    MOV TIME , 0
    
;***********��ѭ�x   
START_MAIN:
    CALL CLE
    CALL SHOW_2            ;��ʾʱ��
    CALL SHOW_DOS   
    CALL KEY_SCAN           ;����ɨ��
    CALL TIME_DATAUP             ;ʱ�����

NEXT_MAIN:
    JMP START_MAIN    
    
;*********����DOS    
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

;*********��λ�������ʾ�ӳ���    
SHOW_2   PROC

    push AX
    push BX
    push DX
    CMP FLAG ,0
    JZ SHOWSPEED

    MOV BL ,10   ;��10����Ĵ���BX�����������λ��
    MOV AL , TIME
    MOV AH , 0
    DIV BL     ;AL/BL,�̷���AL����������AH
    MOV TIME_GE , AH
    MOV AH , 0 
    DIV BL
    MOV TIME_SHI ,AH
    MOV AH , 0 
    
    LEA BX , LED ;������������׵�ַ����BX
    MOV AL , TIME_GE
    XLAT       ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV TIME_GE ,AL
     LEA BX , LED ;������������׵�ַ����BX
    MOV AL , TIME_SHI
    XLAT       ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV TIME_SHI ,AL
    ;��λ
    MOV      DX,L8255_A    ;��8255A�Ŀ����
    MOV      AL , 00000000B   ;�������
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV      AL , 00000001B   ;�Ҳ��������
    OUT      DX,AL
    MOV      DX,L8255_A     ;��8255A�Ŀ����
    MOV      AL,TIME_GE
    OUT      DX,AL   
    
    CALL DELAY1  ;��ʱ

    ;ʮλ
    MOV      DX,L8255_A             ;��8255A�Ŀ����
    MOV      AL , 00000000B   ;�������
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV       AL , 00000010B   ;����������
    OUT      DX,AL
    
    MOV      DX,L8255_A   ;��8255A�Ŀ����
    MOV      AL ,TIME_SHI
    OUT     DX,AL  
     

    CALL DELAY1  ;��ʱ
    JMP SHOW_2END
SHOWSPEED:
    MOV BL ,10   ;��10����Ĵ���BX�����������λ��
    MOV AL , SPEED
    MOV AH , 0
    DIV BL     ;AL/BL,�̷���AL����������AH
    MOV SPEED_GE , AH
    MOV AH , 0 
    DIV BL
    MOV SPEED_SHI ,AH
    MOV AH , 0 
    
    LEA BX , LED ;������������׵�ַ����BX
    MOV AL , SPEED_GE
    XLAT       ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV SPEED_GE ,AL
     LEA BX , LED ;������������׵�ַ����BX
    MOV AL , SPEED_SHI
    XLAT       ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV SPEED_SHI ,AL
    ;��λ
    MOV      DX,L8255_A    ;��8255A�Ŀ����
    MOV      AL , 00000000B   ;�������
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV      AL , 00000001B   ;�Ҳ��������
    OUT      DX,AL
    MOV      DX,L8255_A    ;��8255A�Ŀ����
    MOV      AL,SPEED_GE
    OUT      DX,AL   
    
    CALL DELAY1  ;��ʱ

    ;ʮλ
    MOV      DX,L8255_A              ;��8255A�Ŀ����
    MOV      AL , 00000000B   ;�������
    OUT      DX,AL
    
    MOV      DX,L8255_B
    MOV       AL , 00000010B   ;����������
    OUT      DX,AL
    
    MOV      DX,L8255_A   ;��8255A�Ŀ����
    MOV      AL ,SPEED_SHI
    OUT     DX,AL  
     
    CALL DELAY1  ;��ʱ   
       
    LEA DX,MSG1
    MOV AH,9
    INT 21H
    
    MOV AL ,SPEED
    MOV BUF, AL
    
    MOV BL ,10   ;��10����Ĵ���BX�����������λ��
    MOV AL , SPEED
    MOV AH , 0
    DIV BL     ;AL/BL,�̷���AL����������AH
    MOV SPEED_GE , AH
    MOV AH , 0 
    DIV BL
    MOV SPEED_SHI ,AH
    MOV AH , 0 
    
    MOV AL , SPEED_SHI
    ;ADD AL,30H
    LEA BX , ASC ;������������׵�ַ����BX
    XLAT       ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV DL,AL  ;��dos02�Ź��ܣ�����ַ�
    MOV AH , 02H
    INT 21H
    
    MOV AL , SPEED_GE
    ;ADD AL,30H
    LEA BX , ASC ;������������׵�ַ����BX
    XLAT         ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV DL,AL    ;��dos02�Ź��ܣ�����ַ�
    MOV AH , 02H
    INT 21H    
    
SHOW_2END:    
    pop DX
    pop BX
    pop AX
    RET
SHOW_2      ENDP


    
;*********һλ�������ʾ�ӳ���   
SHOW_1             PROC

    push AX
    push BX
    push DX
    
    CMP TIME ,0FH
    JA SHOW_1_END

    MOV      DX,L8255_B
    MOV      AL , 00000001B   ;�Ҳ��������
    OUT      DX,AL 
    
    LEA BX , LED ;������������׵�ַ����BX
    MOV AL , TIME
    XLAT       ;���ָ���DS��[BX+AL]�������͵�AL��
    ;���   
    MOV      DX,L8255_A    ;8255A�Ŀ����
    OUT      DX,AL    
SHOW_1_END:    
    pop DX
    pop BX
    pop AX
    RET
SHOW_1           ENDP

;*********DOS��ʾ�ӳ���
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
    
    MOV BL ,10   ;��10����Ĵ���BX�����������λ��
    MOV AL , TIME
    MOV AH , 0
    DIV BL     ;AL/BL,�̷���AL����������AH
    MOV TIME_GE , AH
    MOV AH , 0 
    DIV BL
    MOV TIME_SHI ,AH
    MOV AH , 0 
    
    MOV AL , TIME_SHI
    ;ADD AL,30H
    LEA BX , ASC ;������������׵�ַ����BX
    XLAT      ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV DL,AL  ;��dos02�Ź��ܣ�����ַ�
    MOV AH , 02H
    INT 21H
    
    MOV AL , TIME_GE
    ;ADD AL,30H
    LEA BX , ASC ;������������׵�ַ����BX
    XLAT         ;���ָ���DS��[BX+AL]�������͵�AL��
    MOV DL,AL    ;��dos02�Ź��ܣ�����ַ�
    MOV AH , 02H
    INT 21H
    
    MOV DL,','  ;��dos02�Ź��ܣ�����ַ�
    MOV AH , 02H
    INT 21H

 SHOW_DOS_END:    
    pop DX
    pop BX
    pop AX
    RET
SHOW_DOS           ENDP


;*********������ѯ��ʾ�ӳ���,C0�����뿪��

KEY_SCAN       PROC
    push ax
    push bx
    push dx

    MOV DX , L8255_C
    IN  AL  , DX
    AND AL , 00000001B
    CMP AL , 1   ;�ߵ�ƽ����
    JZ K1
    ;����د
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

;*********ʱ������ӳ����ӳ���

TIME_DATAUP            PROC

    push AX
    push BX
    push DX
    
    CMP FLAG ,1
    JZ T1
T0:   

   JMP TIME_DATAUP_END
   
T1:
   MOV AL,10000000B  ;���������2��ֵ
   MOV DX , L8254_K
   OUT DX , AL
   MOV DX , L8254_2
   IN AL , DX         ;������2���ֽ�
   MOV AH , AL        ;�ݴ�AH
   IN AL , DX          ;������2���ֽ�
   XCHG  AH,AL          ;����AX
   MOV NUM , AX      ;�ż���ĩֵ
   MOV BX , 0
   SUB BX ,AX   ;�����̼����ڼ������õ�ʱ�䣨�룩
   
   MOV TIME , BL
   
   
TIME_DATAUP_END:    
    pop DX
    pop BX
    pop AX
    RET
TIME_DATAUP            ENDP


;*********��ʱ�ӳ���
DELAY1           PROC
;�������ʱ
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