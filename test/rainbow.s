.include "macros2.s"

.data
pixel: .string " "
msg1: .string "Pressione S para alterar a cor do arco- iris."
msg2: .string "Pressione Q para sair do programa."

.text
	M_SetEcall(exceptionHandling)	# Macro de SetEcall - não tem ainda na DE1-SoC

	li a5, -1 #primeira cor iniciada com -1 para facilitar calculo
	jal CLS
	jal PRINTSTR1
	jal PRINTSTR2
	jal RainbowConstructor
	jal Efeito

# syscall print string
PRINTSTR1: li a7,104
	la a0,msg1
	li a1,0
	li a2,0
	li a3,0xFF00
	ecall
#	jal exceptionHandling
	ret

PRINTSTR2: li a7,104
	la a0,msg2
	li a1,0
	li a2,32
	li a3,0xFF00
	ecall
#	jal exceptionHandling
	ret

ShiftColors:
	addi sp, sp, -4
	sw ra, 0(sp)

	addi a5, a5, 1
	jal RainbowConstructor

	lw ra, 0(sp)
	addi sp,sp, 4
	ret

Quit:
	jal CLS
	#end
	li a7, 110
	ecall

GetColor:
	li t1, 7
	rem t0,a5,t1            #Remainder: set t0 to the remainder of a5/t0

	#Rosa
	li t1, 0
	beq t0, t1, GetRosa

	#Roxo
	li t1, 1
	beq t0, t1, GetRoxo

	#Azul
	li t1, 2
	beq t0, t1, GetAzul

	#Verde
	li t1, 3
	beq t0, t1, GetVerde

	#Amarelo
	li t1, 4
	beq t0, t1, GetAmarelo

	#Laranja
	li t1, 5
	beq t0, t1, GetLaranja

	#Vermelho
	li t1, 6
	beq t0, t1, GetVermelho

GetRosa:
	li a3,0xD700
	ret

GetRoxo:
	li a3,0xC300
	ret

GetAzul:
	li a3,0xD000
	ret

GetVerde:
	li a3,0x3900
	ret

GetAmarelo:
	li a3,0x3F00
	ret

GetLaranja:
	li a3,0x0F00
	ret

GetVermelho:
	li a3,0x0500
	ret


RainbowConstructor:	#as cores começam no rosa e sao ordenadas de acordo com o modulo 7.
			#cada cor é dada por a5.

	addi sp, sp, -4
	sw ra, 0(sp)

	li s0, 160 #centro horizontal do loop, usado para calcular cada x inicial de cada cor.
	li s1, 48 # raio estabelecido da primira cor mais embaixo, subtraido de 8 (1 unidade) para padronizar calculos.

	mv a4, s1

	#rosa
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	#roxo
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	#azul
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	#verde
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	#amarelo
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	#laranja
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	#vermelho
	addi a5, a5, 1
	addi a4, a4, 8
	sub a1, s0, a4
	jal GetColor
	jal ColorLoop

	lw ra, 0(sp)
	addi sp, sp, 4
	ret



# CLS Clear Screen
CLS:	li a0,0x00	#preto:00, amarelo:3F, azul:D0, rosa: D7, roxo: C3, verde: 39, vermelho: 05, laranja: 0F
	li a7,148
	ecall
#	jal exceptionHandling
	ret

GetCommand:
# syscall read string
	li a7,112
	ecall
#	jal exceptionHandling
	ret

Efeito:
	jal GetCommand

	li t0, 0x00000071
	li t1, 0x00000073

	beq a0, t0, Quit
	beq a0, t1, ShiftColors
	j Efeito

	ret

ColorLoop: #definir COR, RAIO e o X INICIAL antes de chamar, a3 = cor, a4=raio, a1=1ºx
	#cor mais embaixo dada como sendo raio 56.
	#cada pixel assumido como sendo 8 unidades
	#calculo para y=f(x):
	#y = 240 - sqrt(r^2 - 25600 + 320 x - x^2)
	addi a1, a1, 1
	mul t1, a1, a1
	li t2, 320
	mul t2, t2, a1

	li t3, 25600
	mul t0, a4, a4
	sub t3, t0, t3

	sub t1, t2, t1
	add t1, t1, t3
	fcvt.s.w f2, t1         #Convert float from integer: Assigns the value of t1 to f2
	fsqrt.s f1, f2          #Floating SQuare RooT: Assigns f1 to the square root of f2
	fcvt.w.s t1, f1         #Convert integer from float: Assigns the value of f1 (rounded) to t1
	li t2, 240
	sub t1, t2, t1
	mv a2, t1

	#pinta um pixel
	li a7,104
	la a0,pixel
	ecall

	#while x < 160+raio
	addi t0, a4, 160
	bne a1, t0, ColorLoop
	ret

.include "SYSTEMv12.s"
