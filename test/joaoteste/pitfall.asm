.include "macros.s"

.data
pixel: .string " "

.text
	M_SetEcall(exceptionHandling)	# Macro de SetEcall - não tem ainda na DE1-SoC
	jal BACKGROUND
	li a3, 0x00
	li a1, 0
	li a2, 176
	mv s1, a1
	mv s2, a2
	jal PRINTPIXEL
	jal CONTROLE
	
	
	li a7,110
	ecall
	
PRINTPIXEL:
	la a0, pixel	#begin PRINTPIXEL
	li a7, 104
	ecall
	ret	
	
BACKGROUND:
	addi sp, sp, -4	# begin BACKGROUND
	sw ra, 0(sp)
	jal CLS
	li a1, -1
	li a2, 184
	li a3, 0x0500
	li t0, 320
	jal Colision
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
Colision:
	addi a1, a1, 1
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal PRINTPIXEL
	
	lw ra, 0(sp)
	addi, sp, sp, 4
	bne a1, t0, Colision
	ret
	
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
	addi sp, sp, -4	# begin CONTROLE
	sw ra, 0(sp)
	
	jal GetCommand	# gets an input and stores it in a0
	
	li t0, 0x00000020	# SPACE
	li t1, 0x00000064	# D key 
	li t2, 0x00000061	# A key
	li t3, 0x00000077	# W key 
	li t4, 0x00000073	# S key  
	
	beq a0, t0, Jump
	beq a0, t1, PlayerMoveRight
	beq a0, t2, PlayerMoveLeft
	beq a0, t3, PlayerMoveUp
	beq a0, t4, PlayerMoveDown
	j CONTROLE
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	
	
Jump:
	addi sp, sp, -4	# begin Gravity test
	sw ra, 0(sp)
	
	# S = s0 + a * dT
	#jal PlayerMoveUp
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, -20
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	#
	li a7, 32
	li a0, 100
	ecall
	
	#jal PlayerMoveUp
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, -16
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	#
	li a7, 32
	li a0, 100
	ecall
	
	#jal PlayerMoveUp
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, -12
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	#
	li a7, 32
	li a0, 100
	ecall
	
	
	########
	
	#jal PlayerMoveUp
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, 12
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	#
	li a7, 32
	li a0, 100
	ecall
	
	#jal PlayerMoveUp
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, 16
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	#
	li a7, 32
	li a0, 100
	ecall
	
	#jal PlayerMoveUp
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, 20
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	#
	li a7, 32
	li a0, 100
	ecall
	
	

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
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	
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
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
PlayerMoveUp:
	addi sp, sp, -4	# begin PlayerMoveUp
	sw ra, 0(sp)
	
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, -8
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
	
PlayerMoveDown:

	# check for colision
	li t1, 184
	mv a2, s2
	addi a2, a2, 8
	beq a2, t1, Stop
	# done checking
	
	
	addi sp, sp, -4	
	sw ra, 0(sp)
	
	mv a1, s1
	mv a2, s2
	li a3, 0xFFFF
	jal PRINTPIXEL
	
	addi s2, s2, 8
	mv a1, s1
	mv a2, s2
	li a3, 0x00
	jal PRINTPIXEL
	
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

# CLS Clear Screen	(B B G G G R R R)
CLS:	li a0,0xFF	#rgb(121, 210, 121)	
	li a7,148
	ecall
#	jal exceptionHandling
	ret
	
Stop:
	j CONTROLE
	
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
	
	j CONTROLE
	
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
	
	j CONTROLE

.include "SYSTEMv11.s"
