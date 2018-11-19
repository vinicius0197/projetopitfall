.include "macros.s"

.data
pixel: .string " "
colon: .string ":"

.text

	###################
	# Registradores permanentes e como estão sendo utlizados:
	#
	#	s1 = posição horizontal atual Jogador
	#	s2 = posição vertical atual Jogador
	#	s10 = Tempo daqui a 20 min (usado para calculos de Timer)
	#	s11 = Tempo de inicio de programa (usado para calculos de Fisicas)
	#	s3 = set on ZERO se tiver em free fall. Altura do pulo
	#
	#
	###################
	
	M_SetEcall(exceptionHandling)	# Macro de SetEcall - não tem ainda na DE1-SoC
	jal BACKGROUND
	########
	# startando timer
	li a7, 130
	ecall
	mv s11, a0 # tempo inicio de programa
	li a0, 0x00124F80	# 20 minutos
	#li a0, 0x00002710	#10 segundos (para debug)
	add s10, s11, a0	# tempo inicial + 20 min
	# s10=20mmin0segs, initial time
	########
	li a3, 0x00
	li a1, 0
	li a2, 152
	mv s1, a1
	mv s2, a2
	jal PRINTPIXEL
	
	
	li s3, 0
	jal UPDATE
	
	
	li a7,110
	ecall
	
GRAVIDADE:

	addi sp, sp, -4	# begin GRAVIDADE
	sw ra, 0(sp)
	
	
	# check for colision
	li t1, 160
	mv a2, s2
	addi a2, a2, 8
	beq a2, t1, Break
	# done checking
	
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL

	addi s2, s2, 8
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	# end GRAVIDADE
	
UPDATE: 										#update
	li a0, 100	# limitar a velocidade
	li a7, 132
	ecall
	jal TIMER
	jal CheckJump
	jal GRAVIDADE
	jal DrawPlayer
	jal CONTROLE
	j UPDATE
	
	
TIMER:
	addi sp, sp, -4	# begin TIMER
	sw ra, 0(sp)
	li a3, 0x07	# Timer color
	li a1, 0	# Timer horizontal psoition
	li a2, 8	# Timer vertical position
	
	li a7, 130
	ecall
	
	mv t2, a0
	li t3, -1	
	
	
	
	#######
	# calcula os decimal min passados
	
	sub a0, a0, s10
	li t0, 600000
	li t1, 6
	div a0, a0, t0
	rem a0, a0, t1
	
	
	li a7, 101
	mul a0, a0, t3
	ecall
	
	#######
	# calcula os unitario min passados
	mv a0, t2
	
	addi a1, a1, 8
	sub a0, a0, s10
	li t0, 60000
	li t1, 10
	div a0, a0, t0
	rem a0, a0, t1
	
	
	li a7, 101
	mul a0, a0, t3
	ecall
	
	#######
	# printa os doispontos
	la a0, colon
	li a7, 104
	addi a1, a1, 8
	ecall
	#######
	# calcula os decimais de segs passados
	mv a0, t2
	
	
	sub a0, a0, s10
	li t0, 10000
	li t1, 6
	div a0, a0, t0
	rem a0, a0, t1
	
	addi a1, a1, 8
	li a7, 101
	mul a0, a0, t3
	ecall
	
	#######
	# calcula os unidades de segs passados
	mv a0, t2
	
	
	sub a0, a0, s10
	li t0, 1000
	li t1, 10
	div a0, a0, t0
	rem a0, a0, t1
	
	addi a1, a1, 8
	li a7, 101
	mul a0, a0, t3
	ecall
	
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	#end TIMER
	
PRINTPIXEL:
	la a0, pixel	#begin PRINTPIXEL
	li a7, 104
	ecall
	ret	
	
BACKGROUND:
	addi sp, sp, -4	# begin BACKGROUND
	sw ra, 0(sp)
	jal CLS
	li a1, -1	# facilita a função de draw
	li a2, 160	# posição vertical do chão
	li a3, 0x0500	# cor do chão
	li t0, 320	# tamanho de pixels da tela horizontal
	jal DrawFloor
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
DrawFloor:	
	addi a1, a1, 1	# i++
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal PRINTPIXEL
	
	lw ra, 0(sp)
	addi, sp, sp, 4
	bne a1, t0, DrawFloor
	ret
	
DrawPlayer:
	addi sp, sp, -4	# begin DrawPlayer
	sw ra, 0(sp)
	
	li a3, 0x00
	mv a1, s1
	mv a2, s2
	jal PRINTPIXEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawPlayer
	
GetCommand:	
# syscall read string
	li a7,112
	ecall
#	jal exceptionHandling
	ret
	
CONTROLE: 

	######################
	# Keyboard ascii value
	# space = 0x00000020
	# d=0x00000064
	# a=0x00000061
	# w=0x00000077
	# s=0x00000073
	# p=0x00000000
	######################
	addi sp, sp, -4	# begin Controle
	sw ra, 0(sp)
	jal GetCommand	# gets an input and stores it in a0
	
	li t0, 0x00000020	# SPACE
	li t1, 0x00000064	# D key 
	li t2, 0x00000061	# A key
	li t3, 0x00000077	# W key 
	li t4, 0x00000073	# S key  
	
	lw ra, 0(sp)
	addi sp, sp, 4
	
	beq a0, t0, Jump
	beq a0, t1, PlayerMoveRight
	beq a0, t2, PlayerMoveLeft
	
	ret
	
Jump:	
	addi sp, sp, -4	# begin Jump
	sw ra, 0(sp)
	
	bgt s3, zero, Break
	# check for mid air jump
	li t0, 152
	mv a2, s2
	blt a2, t0, Break
	# done checking
	
	li s3, 3	# altura do pulo
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
CheckJump:
	addi sp, sp, -4	# begin CheckJump
	sw ra, 0(sp)
	
	beq s3, zero, Break
	
	
	
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	addi s3, s3, -1
	addi s2, s2, -16
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
			
PlayerMoveRight:

	# check for out of bounds
	li t1, 312
	mv a1, s1
	addi a1, a1, 8
	bgt a1, t1, OutOfBoundsRight
	# end OFB check
	
	
	addi sp, sp, -4	# begin PlayerMoveRight
	sw ra, 0(sp)
	
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s1, s1, 8
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
PlayerMoveLeft:

	# check for out of bounds
	li t1, 0
	mv a1, s1
	addi a1, a1, -8
	blt a1, t1, OutOfBoundsLeft
	# end OFB check
	
	
	addi sp, sp, -4	# begin PlayerMoveLeft
	sw ra, 0(sp)
	
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s1, s1, -8
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

# CLS Clear Screen	(B B G G G R R R)
CLS:	li a0,0xFF	#rgb(121, 210, 121)	
	li a7,148
	ecall
#	jal exceptionHandling
	ret
	
Break:
	#j UPDATE
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
OutOfBoundsRight:
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	li s1, 0
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	
	j UPDATE
	
OutOfBoundsLeft:
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	li s1, 312
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	
	j UPDATE
	
ENDGAME:
	li a7, 110
	ecall

.include "SYSTEMv11.s"
