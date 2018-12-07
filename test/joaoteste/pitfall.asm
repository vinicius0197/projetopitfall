.include "macros.s"
.include "harry.s"
.include "sounds.s"
.include "enemies.s"
.include "background.s"

.data

INTRO: .string "images/intro.bin"
SCENA: .string "images/scenary.bin"
STAND: .string "images/harry/jump1.bin"
colon: .string ":"
vidatext: .string "Vidas: "
pontostext: .string "Pontos: "

LevelCounter: .word 3
PlayerVida: .word 3	# N�mero de vidas do Jogador. Se chegar a zero = game over
PlayerCoord: .word 0, 120, 0 # +0: x coord, +4: y coord, (1o piso=192y, subsolo=120y), +12: isUnderground 0=false, 1=true
EnemyCoord: .word 	0, 0, 0,	# barril 1: x, y, isMoving.
			0, 0, 0,	# barril 2: x, y, isMoving
			0, 0,		# escorpi�o
			0, 0		# fogo
TreasureCoord: .word 0, 0

.text

	###################
	# Registradores permanentes e como estão sendo utlizados:
	#
	#	s1 = endereco das coordenadas atuais Jogador
	#	s2 = endereco das coordenadas atuais Inimigos
	#	s10 = Tempo daqui a 20 min (usado para calculos de Timer)
	#	s11 = endereco das coordenadas do eventual Tesouro
	#	s3 = altura do pulo
	#	s4 = maxheight hold
	#	s5 = Pontua��o
	#
	###################
	
	M_SetEcall(exceptionHandling)	# Macro de SetEcall - não tem ainda na DE1-SoC
	########
	# startando timer
	li a7, 130
	ecall
	mv s10, a0 # tempo inicio de programa
	li a0, 0x00124F80	# 20 minutos
	add s10, s10, a0	# tempo inicial + 20 min
	# s10=20mmin0segs, initial time
	########
	
	
	la s1, PlayerCoord	# armazena endereco de acesso as coordenadas do jogador
	la s2, EnemyCoord	# armazena endereco de acesso as coordenadas dos inimigos
	la s11, TreasureCoord
	li s3, 0
	li s4, 0
	li s5, 2000		# pontua��o inicial
	jal LOADLEVEL	# essa fun��o vai se encarregar de carregar o nivel certo. � chamada sempre em transi��o de niveis. Apenas carrega as posi��es iniciais.
	
UPDATE: 								#update
	li a0, 100	# limitar a velocidade. 100 ms parece bom
	li a7, 132
	ecall
	jal BACKGROUND
	jal HUD
	jal CheckJump
	jal GRAVIDADE
	jal DrawBarrel
	jal DrawPlayer
	jal CONTROLE
	j UPDATE
	
LOADLEVEL:
	addi sp, sp, -4	# begin LOADLEVEL
	sw ra, 0(sp)
	
	
	la t0, LevelCounter
	lw t0, 0(t0)
	
######################
# level 1 START
Level1:	li t1, 1
	bne t0, t1, Level2
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 256	# x pos
	li t1, 120	# y pos
	sw t0, 0(s2)
	sw t1, 4(s2)
	
	
	j EndLoadLevel
# level 1 END
#####################

######################
# level 2 START
Level2:	li t1, 2
	bne t0, t1, Level3
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 256	# x pos
	li t1, 120	# y pos
	sw t0, 0(s2)
	sw t1, 4(s2)
	
	# spawn barril 2
	li t0, 240	# x pos
	li t1, 120	# y pos
	sw t0, 12(s2)
	sw t1, 16(s2)
	
	j EndLoadLevel
# level 2 END
#####################

######################
# level 3 START
Level3:	li t1, 3
	bne t0, t1, Level4
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 3 END
#####################

######################
# level 4 START
Level4:	li t1, 4
	bne t0, t1, Level5
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 4 END
#####################

######################
# level 5 START
Level5:	li t1, 5
	bne t0, t1, Level6
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 5 END
#####################

######################
# level 6 START
Level6:	li t1, 6
	bne t0, t1, Level7
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 6 END
#####################

######################
# level 7 START
Level7:	li t1, 7
	bne t0, t1, Level8
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 7 END
#####################

######################
# level 8 START
Level8:	li t1, 8
	bne t0, t1, Level9
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 8 END
#####################

######################
# level 9 START
Level9:	li t1, 9
	bne t0, t1, Level10
	#carrega inimigos, tesouros, obstaculos, etc
	
	j EndLoadLevel
# level 9 END
#####################

######################
# level 10 START
Level10:	
	#carrega inimigos, tesouros, obstaculos, etc
	
# level 10 END
#####################
	
EndLoadLevel:	lw ra, 0(sp)
	addi sp, sp, 4
	ret	# end LOADLEVEL
	
	
HUD: 
	addi sp, sp, -4	# begin HUD
	sw ra, 0(sp)
	
	jal TIMER
	jal SCORE
	jal LIVES
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	#end HUD	
	
TIMER:
	addi sp, sp, -4	# begin TIMER
	sw ra, 0(sp)
	li a3, 0x07	# Timer color
	li a1, 2	# Timer horizontal psoition
	li a2, 14	# Timer vertical position
	
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
	
SCORE:
	addi sp, sp, -4	# begin SCORE
	sw ra, 0(sp)
	
	li a3, 0x07	# score color
	li a1, 8	# score horizontal position
	li a2, 2	# score vertical position
	
	# texto
	la a0, pontostext
	li a7, 104
	ecall		# comenta essa linha
	
	# pontos
	addi a1, a1, 64	# e essa para remover o texto.
	mv a0, s5	# load points
	li a7, 101
	ecall
		
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	#end SCORE
	
LIVES: 
	addi sp, sp, -4
	sw ra, 0(sp)
	
	li a3, 0x07	# lives color
	li a1, 248	# lives horizontal position
	li a2, 2	# lives vertical position
	la t0, PlayerVida
	
	# texto
	la a0, vidatext
	li a7, 104
	ecall
	
	# numVidas
	
	lw a0, 0(t0)
	addi a1, a1, 56
	li a7, 101
	ecall
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	#end LIVES
	
BACKGROUND:
	bg_level1
	
DrawPlayer:	# 20x24
	addi sp, sp, -4	# begin DrawPlayer
	sw ra, 0(sp)
	
	li a0, 1
	lw a1, 0(s1)
	lw a2, 4(s1)
	harry_print a0, a1, a2
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawPlayer
	
DrawBarrel:	# 20x24
	addi sp, sp, -4	# begin DrawBarrel
	sw ra, 0(sp)
	
	#desenha 1 barril
	lw a2, 4(s2)	# y pos do 1 barril, se for 0 nao tem barril.
	beq a2, zero, NoBarrel
	li a0, 1
	lw a1, 0(s2)
	barrel_print a0, a1, a2
	
	#desenha 2 barris
	lw a2, 16(s2)	# y pos do 2 barril, se for 0 nao tem barril.
	beq a2, zero, NoBarrel
	li a0, 1
	lw a1, 12(s2)
	barrel_print a0, a1, a2
	
NoBarrel:	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawBarrel

	
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
	
GRAVIDADE:

	addi sp, sp, -4	# begin GRAVIDADE
	sw ra, 0(sp)
	
	
	# check for colision upper floor
	li t1, 128
	lw a2, 4(s1)
	addi a2, a2, 8
	beq a2, t1, Break
	# done checking
	
	# check for colision lower floor
	li t1, 200
	lw a2, 4(s1)
	addi a2, a2, 8
	beq a2, t1, Break
	# done checking
	
	
	
	lw a2, 4(s1)
	addi a2, a2, 8

	sw a2, 4(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	# end GRAVIDADE
	
Jump:	
	addi sp, sp, -4	# begin Jump
	sw ra, 0(sp)
	
	bgt s3, zero, Break
	# check for mid air jump
	li t0, 120
	lw a2, 4(s1)
	blt a2, t0, Break
	# done checking
	
	li s3, 3	# altura do pulo
	li s4, 2	# quantos frames na altura maxima
	sound_jump
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
CheckJump:
	addi sp, sp, -4	# begin CheckJump
	sw ra, 0(sp)
	
	beq s3, zero, Break
	
	li t1, 1
		
	beq s3, t1, MaxHeightHold
	
	addi s3, s3, -1
	
	lw a2, 4(s1)
	addi a2, a2, -16
	sw a2, 4(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
MaxHeightHold:
	beq s4, zero, Break
	addi s4, s4, -1
	lw a2, 4(s1)
	addi a2, a2, -8
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
	
	
	
	lw a1, 0(s1)
	addi a1, a1, -8
	sw a1, 0(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

Break:
	#j UPDATE
	li s3, 0
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
OutOfBoundsRight:
	
	li a1, 0
	sw a1, 0(s1)
	jal DrawPlayer
	
	j UPDATE
	
OutOfBoundsLeft:
	
		
	li a1, 312
	sw a1, 0(s1)
	jal DrawPlayer
	
	j UPDATE
	
ENDGAME:
	li a7, 110
	ecall

.include "SYSTEMv11.s"
