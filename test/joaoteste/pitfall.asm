.include "macros.s"

.data
pixel: .string " "
colon: .string ":"
PlayerCoord: .word 0, 0 # +0: x coord, +4: y coord
EnemyCoord: .word 0, 0

.text

	###################
	# Registradores permanentes e como estão sendo utlizados:
	#
	#	s1 = endereco das coordenadas atuais Jogador
	#	s2 = endereco das coordenadas atuais Inimigos
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
	
	li a1, 0
	li a2, 152
	
	la s1, PlayerCoord	# armazena endereco de acesso as coordenadas do jogador
	sw a1, 0(s1)		# x = s1
	sw a2, 4(s1)		# y = s1 + 4
	
	jal DrawPlayer
	
	li a1, 304
	li a2, 152
	
	la s2, EnemyCoord
	sw a1, 0(s2)
	sw a2, 4(s2)
	
	jal DrawBarrel	
	
	li s3, 0
	jal UPDATE
	
	
	li a7,110
	ecall
	
GRAVIDADE:

	addi sp, sp, -4	# begin GRAVIDADE
	sw ra, 0(sp)
	
	
	# check for colision
	li t1, 160
	lw a2, 4(s1)
	addi a2, a2, 8
	beq a2, t1, Break
	# done checking
	
	jal ErasePlayer
	
	lw a2, 4(s1)
	addi a2, a2, 8

	sw a2, 4(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	# end GRAVIDADE
	
UPDATE: 									#update
	li a0, 50	# limitar a velocidade
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
	
	li a1, -1	# facilita a função de draw
	li a2, 232	# posição vertical do chão
	li a3, 0x0570	# cor do chão
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
	
	#####
	
	#			| | |
	#			| | |		principal
	#			|*| |
	
	lw a1, 0(s1)
	lw a2, 4(s1)
	jal PRINTPIXEL
	
	#			| | |
	#			|*| |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			|*| |
	#			| | |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			| |*|
	#			| | |
	#			| | |
	
	addi a1, a1, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| |*|
	#			| | |
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| | |
	#			| |*|
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	
	
	#####
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawPlayer
	
ErasePlayer:
	addi sp, sp, -4	# begin ErasePlayer
	sw ra, 0(sp)
	
	li a3, 0xFFFF
	
	#####
	
	#			| | |
	#			| | |		principal
	#			|*| |
	
	lw a1, 0(s1)
	lw a2, 4(s1)
	jal PRINTPIXEL
	
	#			| | |
	#			|*| |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			|*| |
	#			| | |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			| |*|
	#			| | |
	#			| | |
	
	addi a1, a1, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| |*|
	#			| | |
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| | |
	#			| |*|
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	
	
	#####
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end ErasePlayer
	
DrawScorpion:
	addi sp, sp, -4	# begin DrawScorpion
	sw ra, 0(sp)
	
	li a3, 0xF000
	
	#####
	
	#			| | |		principal
	#			|*| |
	
	lw a1, 0(s2)
	lw a2, 4(s2)
	jal PRINTPIXEL
	
	#			|*| |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			| |*|
	#			| | |
	
	addi a1, a1, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| |*|
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	#####
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawScorpion
	
EraseScorpion:
	addi sp, sp, -4	# begin EraseScorpion
	sw ra, 0(sp)
	
	li a3, 0xFFFF
	
	#####
	
	#			| | |		principal
	#			|*| |
	
	lw a1, 0(s2)
	lw a2, 4(s2)
	jal PRINTPIXEL
	
	#			|*| |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			| |*|
	#			| | |
	
	addi a1, a1, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| |*|
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	#####
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end EraseScorpion
	
	
DrawBarrel:
	addi sp, sp, -4	# begin DrawBarrel
	sw ra, 0(sp)
	
	li a3, 0x7300
	
	#####
	
	#			|*| |		principal
	
	lw a1, 0(s2)
	lw a2, 4(s2)
	jal PRINTPIXEL
	
	#			| |*|
	
	addi a1, a1, 8
	jal PRINTPIXEL
	
	#####
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawBarrel
	
EraseBarrel:
	addi sp, sp, -4	# begin EraseBarrel
	sw ra, 0(sp)
	
	li a3, 0xFFFF
	
	#####
	
	#			| | |		principal
	#			|*| |
	
	lw a1, 0(s2)
	lw a2, 4(s2)
	jal PRINTPIXEL
	
	#			|*| |
	#			| | |
	
	addi a2, a2, -8
	jal PRINTPIXEL
	
	#			| |*|
	#			| | |
	
	addi a1, a1, 8
	jal PRINTPIXEL
	
	#			| | |
	#			| |*|
	
	addi a2, a2, 8
	jal PRINTPIXEL
	
	#####
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end EraseBarrel
	
	
GetCommand:
KEY: 	li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
LOOP: 	lw t0,0(t1)			# Le bit de Controle Teclado
   	sw zero,0(t1)
   	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,EndCommand		# n�o tem tecla pressionada ent�o volta ao loop
   	lw a0,4(t1)			# le o valor da tecla
EndCommand:
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
	lw a2, 4(s1)
	blt a2, t0, Break
	# done checking
	
	li s3, 4	# altura do pulo
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
CheckJump:
	addi sp, sp, -4	# begin CheckJump
	sw ra, 0(sp)
	
	beq s3, zero, Break
		
	jal ErasePlayer
	addi s3, s3, -1
	lw a2, 4(s1)
	addi a2, a2, -16
	sw a2, 4(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
			
PlayerMoveRight:

	# check for out of bounds
	li t1, 312
	lw a1, 0(s1)
	addi a1, a1, 8
	bgt a1, t1, OutOfBoundsRight
	# end OFB check
	
	
	addi sp, sp, -4	# begin PlayerMoveRight
	sw ra, 0(sp)
	
	jal ErasePlayer
	
	lw a1, 0(s1)
	addi a1, a1, 8
	sw a1, 0(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
PlayerMoveLeft:

	# check for out of bounds
	li t1, 0
	lw a1, 0(s1)
	addi a1, a1, -8
	blt a1, t1, OutOfBoundsLeft
	# end OFB check
	
	
	addi sp, sp, -4	# begin PlayerMoveLeft
	sw ra, 0(sp)
	
	jal ErasePlayer
	
	lw a1, 0(s1)
	addi a1, a1, -8
	sw a1, 0(s1)
	
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
	jal ErasePlayer
	
	li a1, 0
	sw a1, 0(s1)
	jal DrawPlayer
	
	j UPDATE
	
OutOfBoundsLeft:
	jal ErasePlayer
		
	li a1, 312
	sw a1, 0(s1)
	jal DrawPlayer
	
	j UPDATE
	
ENDGAME:
	li a7, 110
	ecall

.include "SYSTEMv11.s"
