.include "macros.s"
.include "harry.s"
.include "sounds.s"
.include "enemies.s"
.include "background.s"
.include "bonus.s"

.data

colon: .string ":"
vidatext: .string "Vidas: "
pontostext: .string "Pontos: "

LevelCounter: .word 1
PlayerVida: .word 3	# Número de vidas do Jogador. Se chegar a zero = game over
PlayerCoord: .word 0, 123	# +0: x coord, +4: y coord, (1o piso=123y, subsolo=195y)
EnemyCoord: .word 0, 0, 0,		# barril 1: x, y, isMoving.
			0, 0, 0,	# barril 2: x, y, isMoving
			0, 0,		# escorpião
			0, 0,		# cobra
			0, 0		# crocodile mouth open flag e timer of last change state	
TreasureCoord: .word 264, 131,	# x, y pos of treasure
			3, 5, 10	# flags de controle pra saber se tesouro já foi pego e em quais niveis tem algum tesouro (max 3 por enquanto)

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
	#	s5 = Pontuação
	#
	###################
	
	M_SetEcall(exceptionHandling)	# Macro de SetEcall - não tem ainda na DE1-SoC
	jal STARTUP
	
UPDATE: 								#update
	li a0, 50	# limitar a velocidade. 100 ms parece bom. DESLIGAR ANTES DE RODAR NA PLACA
	li a7, 132
	ecall
	jal GAMEOVERCHECK
	jal BACKGROUND
	jal HUD
	jal CheckJump
	jal GRAVIDADE
	jal DRAW
	jal COLISION
	jal CONTROLE
	j UPDATE

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
	li t5, 5	
	
	beq t0, t5, CrocBG
	
	rem t4, t0, t3	# resto da divisão do nivel por 3 vai dar o bg certo
	
	beq t4, zero, LoadBG3
	beq t4, t1, LoadBG1
	beq t4, t2, LoadBG2
	
	#se chegar aqui encerra pois bugou
	#nunca sera executado
	li a7, 110
	ecall
	
LoadBG1:		bg_level1
LoadBG2:		bg_level2
LoadBG3:		bg_level3
LoadBGCrocClose:	bg_level4
LoadBGCrocOpen:		bg_level5
LoadIntro:		intro

CrocBG:
	lw t0, 40(s2)	# isMouthOpen
	lw a1, 44(s2)	# timer do ultimo changestate 
		
	li a7, 130
	ecall
	
	sub a2, a0, a1
	li t3, 2500
	
	bgeu a2, t3, ChangeState	
	
	beq t0, t1, LoadBGCrocOpen
	beq t0, zero, LoadBGCrocClose
	
ChangeState:
	sw a0, 44(s2)
	addi t0, t0, 1
	rem t0, t0, t2
	sw t0, 40(s2)
	
	beq t0, t1, LoadBGCrocOpen
	beq t0, zero, LoadBGCrocClose
	
DRAW:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal DrawSnake
	jal DrawBarrel
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
	li t1, 131
	lw a2, 4(s1)
	addi a2, a2, 8
	beq a2, t1, Break
	# done checking
	
	# check for colision lower floor
	li t1, 203
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
	
	beq t1, a1, CheckFirstBarrelColision 	# verifica se player esta na mesma posicao do barril
EndFirstBarrelColision:

	# Check Colision with Barrel 2
	li t3, 2
	lw a1, 12(s2)	# x pos barrel 2
	lw a2, 16(s2)	# y pos barrel 2
	addi a2, a2, -8	# adaptado pra coincidir com o mesmo plano que o player anda.
	
	beq t1, a1, CheckSecondBarrelColision 	# verifica se player esta na mesma posicao do barril
EndSecondBarrelColision:

	# Check Colision with Treasure
	lw a1, 0(s11)	# x pos treasure
	lw a2, 4(s11)	# y pos treasure
	addi a2, a2, -8	# adaptado pra coincidir com o mesmo plano que o player anda.
	
	la a0, LevelCounter
	lw a0, 0(a0)	# LC
	
	lw a3, 8(s11)	# nivel onde se encontra o 1 tesouro
	bne a0, a3, TCaux1	# verifica se esta no nivel do 1 tesouro; se nao estiver vai verificar se esta no nivel do 2 tesouro
	li a4, 1
	beq t1, a1, CheckTreasureColision 	# verifica se player esta na mesma posicao do tesouro
	
TCaux1:	lw a3, 12(s11)	# nivel onde se encontra o 2 tesouro
	bne a0, a3, TCaux2	# verifica se esta no nivel do 2 tesouro; se nao estiver vai verificar se esta no nivel do 3 tesouro
	li a4, 2
	beq t1, a1, CheckTreasureColision 	# verifica se player esta na mesma posicao do tesouro
	
TCaux2:	lw a3, 16(s11)	# nivel onde se encontra o 3 tesouro
	bne a0, a3, EndTreasureColision	# verifica se esta no nivel do 3 tesouro; se nao estiver entao nao esta em um nivel de tesouro logo nao vai haver colisao
	li a4, 3
	beq t1, a1, CheckTreasureColision 	# verifica se player esta na mesma posicao do tesouro
EndTreasureColision:

	# Check Colision with Snake
	lw a1, 32(s2)	# x pos snake
	lw a2, 36(s2)	# y pos snake
	
	beq t1, a1, CheckSnakeColision 	# verifica se player esta na mesma posicao da cobra
	addi a1, a1, -8
	beq t1, a1, CheckSnakeColision 	# verifica se player esta um pixel a esquerda da posicao da cobra
	addi a1, a1, 16
	beq t1, a1, CheckSnakeColision 	# verifica se player esta um pixel a direita da posicao da cobra
EndSnakeColision:

	# Check level 5 colisions
	la a0, LevelCounter
	lw a0, 0(a0)	# LC
	li a1, 5
	bne a1, a0, EndCrocodileColision	# se nao é nivel 5, nao precisa checar nem agua nem crocodilo
	
	# Check Colision with Water
	li a1, 96
	beq t1, a1, CheckWaterColision
	addi a1, a1, 8
	beq t1, a1, CheckWaterColision
	addi a1, a1, 8
	beq t1, a1, CheckWaterColision
	addi a1, a1, 32
	beq t1, a1, CheckWaterColision
	addi a1, a1, 32
	beq t1, a1, CheckWaterColision
	addi a1, a1, 32
	beq t1, a1, CheckWaterColision
	addi a1, a1, 8
	beq t1, a1, CheckWaterColision
	
EndWaterColision:
		
	# Check Colision with Crocodile
	li a1, 120
	beq t1, a1, CheckCrocodileColision
	addi a1, a1, 32
	beq t1, a1, CheckCrocodileColision
	addi a1, a1, 32
	beq t1, a1, CheckCrocodileColision
EndCrocodileColision:

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
	
	li t3, 2500
	add s5, s5, t3	# score +2500
	jal SoundBling
	# zerar tesouro correto
	li t3, 1
	li t4, 2
	li t5, 3
	beq a4, t3, FirstTC
	beq a4, t4, SecondTC
	beq a4, t5, ThirdTC
	
FirstTC:
	sw zero, 8(s11)	
	j ExitTC
SecondTC:
	sw zero, 12(s11)
	j ExitTC
ThirdTC:
	sw zero, 16(s11)	
ExitTC:	lw ra, 0(sp)
	addi sp, sp, 4
	j EndTreasureColision
	
CheckFirstBarrelColision:	### barril 1
	beq t2, a2, FirstBarrelColision	# verifica se player esta no ar
	j EndFirstBarrelColision
	
FirstBarrelColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	addi s5, s5, -20	# score -20
	jal SoundHit
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j EndFirstBarrelColision
	
CheckSecondBarrelColision:	### barril 2
	beq t2, a2, SecondBarrelColision	# verifica se player esta no ar
	j EndSecondBarrelColision
	
SecondBarrelColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	addi s5, s5, -20	# score -20
	jal SoundHit
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j EndSecondBarrelColision
	
CheckSnakeColision:	
	beq t2, a2, SnakeColision	# verifica se player esta no ar
	j EndSnakeColision
	
SnakeColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal SoundHit
	jal PlayerDeath
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j EndSnakeColision
	
CheckWaterColision:	
	li a2, 123
	beq t2, a2, WaterColision	# verifica se player esta no ar
	j EndWaterColision
	
WaterColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal SoundBling
	jal PlayerDeath
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j EndWaterColision
	
CheckCrocodileColision:
	li a2, 123
	lw a1, 40(s2)
	beq a1, zero, EndCrocodileColision
	beq t2, a2, CrocodileColision	# verifica se player esta no ar
	j EndCrocodileColision
	
CrocodileColision:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal SoundHit
	jal PlayerDeath
	
	lw ra, 0(sp)
	addi sp, sp, 4
	j EndCrocodileColision
	
###### end of aux colision calls ######

PlayerDeath:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	la a0, PlayerVida
	lw a1, 0(a0)	# HP
	
	addi a1, a1, -1
	
	sw a1, 0(a0)
	
	li a1, 0	# respawn Player
	li a2, 83
	sw a1, 0(s1)
	sw a2, 4(s1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
GameOverLose:
	jal HUD
	jal SoundGameOverLose
	
	addi sp, sp, 4
	
	li a7, 110
	ecall
	
GameOverWin:
	jal HUD
	jal SoundGameOverWin
	
	addi sp, sp, 4
	
	li a7, 110
	ecall
	
GAMEOVERCHECK:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	# Hit Points Check
	la a0, PlayerVida
	lw a1, 0(a0)	# HP
	beq a1, zero, GameOverLose
	
	# Out Of Time Check
	li a7, 130
	ecall
	bge a0, s10, GameOverLose

	# All Treasures Collected Check
	lw a0, 8(s11)
	lw a1, 12(s11)
	lw a2, 16(s11)	
	bne a0, zero, EndTGOCheck
	bne a1, zero, EndTGOCheck
	beq a2, zero, GameOverWin		
EndTGOCheck:

	lw ra, 0(sp)
	addi sp, sp, 4
	ret

STARTUP:	# carrega todos os registradores e memória corretamente
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal Intro
	
	########
	# startando timer
	li a7, 130
	ecall
	mv s10, a0 # tempo inicio de programa
	li a0, 0x00124F80	# 20 minutos
	#li a0, 0x00001000	# 3 Segundos (para teste de Game Over)
	add s10, s10, a0	# tempo inicial + 20 min
	# s10=20mmin0segs, initial time
	########
	
	la s1, PlayerCoord	# armazena endereco de acesso as coordenadas do jogador
	la s2, EnemyCoord	# armazena endereco de acesso as coordenadas dos inimigos
	la s11, TreasureCoord
	li s3, 0
	li s4, 0
	li s5, 2000		# pontuação inicial
	
	#jal RandomizeStartingLevel	# se comentar, vai carregar o nivel 1. Deixe comentado para ser fiel ao original. Descomente pra mais variedade.
	jal LOADLEVEL	# essa função vai se encarregar de carregar o nivel certo. É chamada sempre em transição de niveis. Apenas carrega as posições iniciais.
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
RandomizeStartingLevel:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	li a7, 130
	ecall
	li a1, 9
	li a7, 42
	ecall
	addi a0, a0, 1
	la a1, LevelCounter
	sw a0, 0(a1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
Intro: 
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal LoadIntro
	
	li a0, 2000	# pseudo load
	li a7, 132
	ecall
	
	li a0, 0x00
	li a7, 148
	ecall
	
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
	
SoundBling:
	sound_gold
	
SoundGameOverLose:
	sound_game_over
	
SoundGameOverWin:
	sound_next_level
	






#load level aqui pra despoluir um pouco


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
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 120	# x pos
	li t1, 131	# y pos
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
	li t0, 320	# x pos
	li t1, 131	# y pos
	li t2, 1	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 200	# x pos
	li t1, 131	# y pos
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
	li t0, 160	# x pos
	li t1, 123	# y pos
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
	li t0, 40	# x pos
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 120	# x pos
	li t1, 131	# y pos
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
	li t0, 168	# x pos
	li t1, 131	# y pos
	li t2, 1	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 200	# x pos
	li t1, 131	# y pos
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
# level 6 END
#####################

######################
# level 7 START
Level7:	li t1, 7
	bne t0, t1, Level8
	#carrega inimigos, tesouros, obstaculos, etc
	
	# spawn barril 1
	li t0, 40	# x pos
	li t1, 131	# y pos
	li t2, 1	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 184	# x pos
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 160	# x pos
	li t1, 123	# y pos
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
	li t0, 16	# x pos
	li t1, 131	# y pos
	li t2, 1	# isMoving flag
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
	li t0, 136	# x pos
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 184	# x pos
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 160	# x pos
	li t1, 123	# y pos
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
	li t0, 280	# x pos
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 0(s2)
	sw t1, 4(s2)
	sw t2, 8(s2)
	
	# spawn barril 2
	li t0, 296	# x pos
	li t1, 131	# y pos
	li t2, 0	# isMoving flag
	sw t0, 12(s2)
	sw t1, 16(s2)	
	sw t2, 20(s2)
	
	# spawn snake
	li t0, 16	# x pos
	li t1, 123	# y pos
	sw t0, 32(s2)
	sw t1, 36(s2)
	
# level 10 END
#####################
	
EndLoadLevel:	lw ra, 0(sp)
	addi sp, sp, 4
	ret	# end LOADLEVEL

.include "SYSTEMv11.s"
