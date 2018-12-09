.include "macros.s"
.include "harry.s"
.include "sounds.s"
.include "enemies.s"
.include "background.s"
.include "bonus.s"

.data

#INTRO: .string "images/intro.bin"
#SCENA: .string "images/scenary.bin"
#STAND: .string "images/harry/jump1.bin"
colon: .string ":"
vidatext: .string "Vidas: "
pontostext: .string "Pontos: "

LevelCounter: .word 2
PlayerVida: .word 3	# Nï¿½mero de vidas do Jogador. Se chegar a zero = game over
PlayerCoord: .word 0, 120, 0 # +0: x coord, +4: y coord, (1o piso=192y, subsolo=120y), +12: isUnderground 0=false, 1=true
EnemyCoord: .word 	0, 0, 0,	# barril 1: x, y, isMoving.
			0, 0, 0,	# barril 2: x, y, isMoving
			0, 0,		# escorpiï¿½o
			0, 0		# cobra		
TreasureCoord: .word 	264, 128,	# x, y pos of treasure
			0, 5, 7	# flags de controle pra saber se tesouro já foi pego e em quais niveis tem algum tesouro (mas 3 por enquanto)

.text

	###################
	# Registradores permanentes e como estÃ£o sendo utlizados:
	#
	#	s1 = endereco das coordenadas atuais Jogador
	#	s2 = endereco das coordenadas atuais Inimigos
	#	s10 = Tempo daqui a 20 min (usado para calculos de Timer)
	#	s11 = endereco das coordenadas do eventual Tesouro
	#	s3 = altura do pulo
	#	s4 = maxheight hold
	#	s5 = Pontuaï¿½ï¿½o
	#
	###################
	
	M_SetEcall(exceptionHandling)	# Macro de SetEcall - nÃ£o tem ainda na DE1-SoC
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
	li s5, 2000		# pontuaï¿½ï¿½o inicial
	jal LOADLEVEL	# essa funï¿½ï¿½o vai se encarregar de carregar o nivel certo. ï¿½ chamada sempre em transiï¿½ï¿½o de niveis. Apenas carrega as posiï¿½ï¿½es iniciais.
	
UPDATE: 								#update
	li a0, 100	# limitar a velocidade. 100 ms parece bom. DESLIGAR ANTES DE RODAR NA PLACA
	li a7, 132
	#ecall
	jal BACKGROUND
	jal HUD
	jal CheckJump
	jal GRAVIDADE
	jal DRAW
	jal COLISION
	jal CONTROLE
	j UPDATE
	
LOADLEVEL:	###### MUST DESPAWN (SET TO 0) IF NOT USED!!!! ######
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
	li t1, 128	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
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
	li t1, 128	# y pos
	li t2, 1	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 200	# x pos
	li t1, 128	# y pos
	li t2, 1	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 2 END
#####################

######################
# level 3 START
Level3:	li t1, 3
	bne t0, t1, Level4
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)	
	
	j EndLoadLevel
# level 3 END
#####################

######################
# level 4 START
Level4:	li t1, 4
	bne t0, t1, Level5
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 4 END
#####################

######################
# level 5 START
Level5:	li t1, 5
	bne t0, t1, Level6
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 5 END
#####################

######################
# level 6 START
Level6:	li t1, 6
	bne t0, t1, Level7
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 6 END
#####################

######################
# level 7 START
Level7:	li t1, 7
	bne t0, t1, Level8
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 7 END
#####################

######################
# level 8 START
Level8:	li t1, 8
	bne t0, t1, Level9
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 8 END
#####################

######################
# level 9 START
Level9:	li t1, 9
	bne t0, t1, Level10
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 0	# x pos
	li t1, 0	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
	j EndLoadLevel
# level 9 END
#####################

######################
# level 10 START
Level10:	
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 0	# x pos
	li t1, 0	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 256	# x pos
	li t1, 124	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
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
	la t0, LevelCounter
	lw t0, 0(t0)	# level
	li t1, 1	
	li t2, 2
	li t3, 3
	
	rem t4, t0, t3	# resto da divisão do nivel por 3 vai dar o bg certo
	
	beq t4, zero, LoadBG1
	beq t4, t1, LoadBG2
	beq t4, t2, LoadBG3
	
	#se chegar aqui encerra pois bugou
	#nunca sera executado
	li a7, 110
	ecall
	
LoadBG1:	bg_level1
LoadBG2:	bg_level2
LoadBG3:	bg_level3
	
DRAW:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal DrawBarrel
	#jal DrawScorpion
	jal DrawSnake
	jal DrawTreasure
	jal DrawPlayer
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

DrawTreasure:	# 20x24	Will only spawn in certain levels. If spawn control = 0 then player has already collected
	addi sp, sp, -4	# begin DrawPlayer
	sw ra, 0(sp)
	
	la t0, LevelCounter
	lw t0, 0(t0)	# nivel atual
	
	li a0, 1	
	lw a1, 0(s11)	# x pos treasure
	lw a2, 4(s11)	# y pos treasure
	
	lw t1, 8(s11)	# primeiro nivel com tesouro
	bne t0, t1, Taux1
	beq t1, zero, NoMob
	jal GoldbagPrint
	j Taux3
	
Taux1:	lw t1, 12(s11)	# segundo nivel com tesouro
	bne t0, t1, Taux2
	beq t1, zero, NoMob
	jal GoldbagPrint
	j Taux3
	
Taux2:	lw t1, 16(s11)	# terceiro nivel com tesouro
	bne t0, t1, Taux3
	beq t1, zero, NoMob
	jal GoldbagPrint
	j Taux3	
	
Taux3:	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawPlayer
			
DrawSnake:	# 20x24
	addi sp, sp, -4	# begin DrawPlayer
	sw ra, 0(sp)
	
	
	lw a2, 36(s2)	# y pos da snake, se for 0 nao tem.
	beq a2, zero, NoMob
	li a0, 1
	lw a1, 32(s2)
	jal SnakePrint
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawPlayer
	
DrawPlayer:	# 20x24
	addi sp, sp, -4	# begin DrawPlayer
	sw ra, 0(sp)
	
	li a0, 1
	lw a1, 0(s1)
	lw a2, 4(s1)
	jal HarryPrint
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawPlayer
	
DrawBarrel:	# 20x24
	addi sp, sp, -4	# begin DrawBarrel
	sw ra, 0(sp)
	
	jal CheckBarrel
	
	#desenha 1 barril
	lw a2, 4(s2)	# y pos do 1 barril, se for 0 nao tem barril.
	beq a2, zero, NoMob
	li a0, 1
	lw a1, 0(s2)
	jal BarrelPrint
	
	#desenha 2 barris
	lw a2, 16(s2)	# y pos do 2 barril, se for 0 nao tem barril.
	beq a2, zero, NoMob
	li a0, 1
	lw a1, 12(s2)
	jal BarrelPrint
	
NoMob:	lw ra, 0(sp)
	addi sp, sp, 4
	ret		# end DrawBarrel
	
CheckBarrel:
	li t0, 1
	lw t1, 8(s2)	# isMoving do barril 1
	lw t2, 20(s2)	# isMoving do barril 2
	
	beq t0, t1, Moving1
aux:	beq t0, t2, Moving2
	
	ret
Moving1:
	# check for out of bounds
	li t1, 0
	lw a1, 0(s2)
	addi a1, a1, -8
	blt a1, t1, BarrelOutOfBounds1
	# end OFB check
	
	lw a1, 0(s2)
	addi a1, a1, -8
	sw a1, 0(s2)
	
	j aux
	
Moving2:
	# check for out of bounds
	li t1, 0
	lw a1, 12(s2)
	addi a1, a1, -8
	blt a1, t1, BarrelOutOfBounds2
	# end OFB check
	
	lw a1, 12(s2)
	addi a1, a1, -8
	sw a1, 12(s2)
	
	ret
	
BarrelOutOfBounds1:
	li a1, 320	########### barrel out of bounds
	sw a1, 0(s2)	# updates barrel x pos
	
	j Moving1
	
BarrelOutOfBounds2:
	li a1, 320	########### barrel out of bounds
	sw a1, 12(s2)	# updates barrel x pos
	
	j Moving2
	
GetCommand:
KEY: 	li t1,0xFF200000		# carrega o endereï¿½o de controle do KDMMIO
LOOP: 	lw t0,0(t1)			# Le bit de Controle Teclado
   	sw zero,0(t1)
   	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,EndCommand		# nï¿½o tem tecla pressionada entï¿½o volta ao loop
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
	jal SoundJump	# isso ta ocupando muiiito tempo
	
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
	li t1, 304
	lw a1, 0(s1)
	addi a1, a1, 8
	bgt a1, t1, PlayerOutOfBoundsRight
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
	li t1, 8
	lw a1, 0(s1)
	addi a1, a1, -8
	blt a1, t1, PlayerOutOfBoundsLeft
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
	
PlayerOutOfBoundsRight:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	la t0, LevelCounter
	lw t2, 0(t0)	# t2 = level
	
	li a1, 0
	sw a1, 0(s1)	# updates player x pos
	
	# check if last level
	li t1, 10
	li a0, 1	# level to load if condition is true
	beq t2, t1, SetLevel
	
	addi t2, t2, 1
	
	sw t2, 0(t0)
	
	jal LOADLEVEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j UPDATE
	
PlayerOutOfBoundsLeft:
	addi sp, sp, -4
	sw ra, 0(sp)

	la t0, LevelCounter
	lw t2, 0(t0)	# t2 = level
	
	li a1, 304
	sw a1, 0(s1)	# updates player x pos
	
	# check if first level
	li t1, 1
	li a0, 10	# level to load if condition is true
	beq t2, t1, SetLevel
	
	addi t2, t2, -1
	
	sw t2, 0(t0)
	
	jal LOADLEVEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j UPDATE
	
SetLevel:
	sw a0, 0(t0)
	jal LOADLEVEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j UPDATE
	
COLISION:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	lw t1, 0(s1)	# x pos player
	lw t2, 4(s1)	# y pos player
	
	# Check Colision with Barrel 1
	lw a1, 0(s2)	# x pos barrel 1
	lw a2, 4(s2)	# y pos barrel 1
	addi a2, a2, -8	# adaptado pra coincidir com o mesmo plano que o player anda.
	
	beq t1, a1, CheckFirstBarrelColision 	# verifica se player esta na mesma posição do barril
EndFirstBarrelColision:

	# Check Colision with Barrel 2
	li t3, 2
	lw a1, 12(s2)	# x pos barrel 2
	lw a2, 16(s2)	# y pos barrel 2
	addi a2, a2, -8	# adaptado pra coincidir com o mesmo plano que o player anda.
	
	beq t1, a1, CheckSecondBarrelColision 	# verifica se player esta na mesma posição do barril
EndSecondBarrelColision:

	# Check Colision with Treasure
	lw a1, 0(s11)	# x pos treasure
	lw a2, 4(s11)	# y pos treasure
	addi a2, a2, -8	# adaptado pra coincidir com o mesmo plano que o player anda.
	
	la a0, LevelCounter
	lw a0, 0(a0)	# LC
	
	lw a3, 8(s11)
	bne a0, a3, TCaux1
	li a4, 1
	beq t1, a1, CheckTreasureColision 	# verifica se player esta na mesma posição do tesouro
	
TCaux1:	lw a3, 12(s11)
	bne a0, a3, TCaux2
	li a4, 2
	beq t1, a1, CheckTreasureColision 	# verifica se player esta na mesma posição do tesouro
	
TCaux2:	lw a3, 16(s11)
	bne a0, a3, EndTreasureColision
	li a4, 3
	beq t1, a1, CheckTreasureColision 	# verifica se player esta na mesma posição do tesouro
EndTreasureColision:
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
	
###### aux colision calls ######

CheckTreasureColision:	### tesouro
	beq t2, a2, TreasureColision	# verifica se player esta no ar
	j EndTreasureColision
	
TreasureColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	addi s5, s5, 2000	# score +2500
	#jal SoundBling
	# zerar tesouro correto
	j EndTreasureColision
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
CheckFirstBarrelColision:	### barril 1
	beq t2, a2, FirstBarrelColision	# verifica se player esta no ar
	j EndFirstBarrelColision
	
FirstBarrelColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	addi s5, s5, -20	# score -20
	jal SoundHit
	
	j EndFirstBarrelColision
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
CheckSecondBarrelColision:	### barril 2
	beq t2, a2, SecondBarrelColision	# verifica se player esta no ar
	j EndSecondBarrelColision
	
SecondBarrelColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	addi s5, s5, -20	# score -20
	jal SoundHit
	
	j EndSecondBarrelColision
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
	
GoldbagPrint:	# necessario para evitar leak de memoria, devido a um ret
	goldbag_print a0, a1, a2	
	
BarrelPrint:	# necessario para evitar leak de memoria, devido a um ret
	barrel_print a0, a1, a2
	
SnakePrint:	# necessario para evitar leak de memoria, devido a um ret
	snake_print a0, a1, a2
	
HarryPrint:	# necessario para evitar leak de memoria, devido a um ret
	harry_print a0, a1, a2
	
SoundJump:	# necessario para evitar leak de memoria, devido a um ret
	sound_jump
	
SoundHit:	# necessario para evitar leak de memoria, devido a um ret
	sound_hit

.include "SYSTEMv11.s"
