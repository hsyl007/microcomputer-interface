CODE	SEGMENT 
        ASSUME CS:CODE

START:
	PA EQU 10H	;A��
	PB EQU 12H	;B��
	PC EQU 14H	;C��
	CW8255 EQU 16H	;8255�����ּĴ���

	T0 EQU 30H	;��ʱ��0
	T1 EQU 32H	;��ʱ��1
	;T2 EQU 34H	;��ʱ��2
	CW8253 EQU 36H ;8253���ƼĴ���
	
	MOV AL,10010001B     ;��ʼ��8255�����֣�A�鹤����ʽ0�����롣B�鹤����ʽ0�������C���4λ�������4λ���롣
	OUT CW8255,AL	;���ƿ�
	
	
	MOV AL,00110110B	;������0���ȵ�8���8����ʽ3�������Ƽ���
	OUT CW8253,Al
	MOV AL,01110110B	;������1���ȵ�8���8����ʽ3�������Ƽ���
	OUT CW8253,Al
	MOV AX,20000D	;������0������ֵ4E20H��20000��������1Hz��������
	OUT T0,AL		;��д��
	MOV AL,AH
	OUT T0,AL		;��д��
	MOV AX,10000D	;������1������ֵ2710H��10000��������2Hz��������
	OUT T1,AL		;��д��
	MOV AL,AH
	OUT T1,AL		;��д��
	MOV BL,00H
	MOV CX,08H
	MOV DL,0FFH
	
AGAIN:
	MOV AX,0000H;
	MOV AL,BL
	OUT PB,AL		;ADC0808λѡ
	IN AL,PC		;ȡPC�ڵ�ֵ����֤��ֵ��Ӱ��PCԭ�е�ֵ��
	OR AL,00100000B	;��ALE�źţ������أ�
	OUT PC,AL;
	AND AL,11011111B;��START�źţ��½��أ�
	OUT PC,AL;
	NOP				;�ղ����ȴ�ת��

WAIT1:	
	IN AL,PC
	AND AL,00000010B	;��EOC״̬
	JZ WAIT1		;��һ�����ִ�н��Ϊ0����ת��1���������ִ�С�
	IN AL,PC
	OR AL,01000000B		;��OE
	OUT PC,AL		;����������ź�
	IN AL,PA		;ȡA������
	CMP AL,153D		;�ж�ȡ����ֵ�Ƿ����3V
	
	;MOV AL,DL		;��DL��ֵ������AL
	;JB NEXT1		;AL<3V����ת
	JB SKIP
	
	;AND AL,0FEH		;����99H,���һλ��0��Ȼ������
	MOV DL,00H
	
;NEXT1:
	;CMP CX,01H
	;JNA SKIP		;CX������1���� 
	;ROL AL,01H		;С��99H�����һλ���䣬ֱ������
SKIP:
	;MOV DL,AL
	
	INC BL			;ѡ����һ·���
	LOOP AGAIN
	CMP DL,0FFH		;�ж����ޱ���������(ax-bx����0 cf=0 zf=1)
	JNB NEXT		;û��������������ʼ���� ��jnb ��תָ�������CF=0��
	IN AL,PC		;ȡC������
	AND AL,01H		;ȡPC0
	JNZ NEXT		;���PC0����0�����ؿ���,��ִ������Ĵ��루��������������������������
	IN AL,PC	
	OR AL,00010000B
	OUT PC,AL		;��GATE
	MOV DL,0FFH	
	MOV CX,08H
	JMP AGAIN
NEXT:
	IN AL,PC	
	AND AL,11101111B
	OUT PC,AL	;��GATE
	MOV DL,0FFH	
	MOV CX,08H
	JMP AGAIN
CODE    ENDS
        END START