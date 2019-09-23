CODE	SEGMENT 
        ASSUME CS:CODE

START:
	PA EQU 10H	;A口
	PB EQU 12H	;B口
	PC EQU 14H	;C口
	CW8255 EQU 16H	;8255控制字寄存器

	T0 EQU 30H	;定时器0
	T1 EQU 32H	;定时器1
	;T2 EQU 34H	;定时器2
	CW8253 EQU 36H ;8253控制寄存器
	
	MOV AL,10010001B     ;初始化8255控制字，A组工作方式0，输入。B组工作方式0，输出。C组高4位输出，低4位输入。
	OUT CW8255,AL	;控制口
	
	
	MOV AL,00110110B	;计数器0，先低8后高8，方式3，二进制计数
	OUT CW8253,Al
	MOV AL,01110110B	;计数器1，先低8后高8，方式3，二进制计数
	OUT CW8253,Al
	MOV AX,20000D	;计数器0，赋初值4E20H（20000），产生1Hz连续方波
	OUT T0,AL		;先写低
	MOV AL,AH
	OUT T0,AL		;再写高
	MOV AX,10000D	;计数器1，赋初值2710H（10000），产生2Hz连续方波
	OUT T1,AL		;先写低
	MOV AL,AH
	OUT T1,AL		;再写高
	MOV BL,00H
	MOV CX,08H
	MOV DL,0FFH
	
AGAIN:
	MOV AX,0000H;
	MOV AL,BL
	OUT PB,AL		;ADC0808位选
	IN AL,PC		;取PC口的值（保证赋值后不影响PC原有的值）
	OR AL,00100000B	;送ALE信号（上升沿）
	OUT PC,AL;
	AND AL,11011111B;送START信号（下降沿）
	OUT PC,AL;
	NOP				;空操作等待转换

WAIT1:	
	IN AL,PC
	AND AL,00000010B	;读EOC状态
	JZ WAIT1		;上一条语句执行结果为0则跳转，1则继续向下执行。
	IN AL,PC
	OR AL,01000000B		;开OE
	OUT PC,AL		;输出读允许信号
	IN AL,PA		;取A口数据
	CMP AL,153D		;判断取出的值是否大于3V
	
	;MOV AL,DL		;将DL的值，赋给AL
	;JB NEXT1		;AL<3V，跳转
	JB SKIP
	
	;AND AL,0FEH		;大于99H,最后一位置0，然后左移
	MOV DL,00H
	
;NEXT1:
	;CMP CX,01H
	;JNA SKIP		;CX不大于1则跳 
	;ROL AL,01H		;小于99H，最后一位不变，直接左移
SKIP:
	;MOV DL,AL
	
	INC BL			;选择下一路输出
	LOOP AGAIN
	CMP DL,0FFH		;判断有无报警被触发(ax-bx等于0 cf=0 zf=1)
	JNB NEXT		;没有则跳过，有则开始报警 （jnb 跳转指令，条件：CF=0）
	IN AL,PC		;取C口数据
	AND AL,01H		;取PC0
	JNZ NEXT		;如果PC0等于0（开关开）,则执行下面的代码（报警），否则跳过（不报警）
	IN AL,PC	
	OR AL,00010000B
	OUT PC,AL		;开GATE
	MOV DL,0FFH	
	MOV CX,08H
	JMP AGAIN
NEXT:
	IN AL,PC	
	AND AL,11101111B
	OUT PC,AL	;关GATE
	MOV DL,0FFH	
	MOV CX,08H
	JMP AGAIN
CODE    ENDS
        END START