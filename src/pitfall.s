#########################################################
#  OAC 					  		#
#  Grupo 6				  		#
#########################################################
.include "harry.s"
.include "sounds.s"
.include "enemies.s"
.include "background.s"

.data

.text

MAIN:
	jal LEVEL1
	jal HARRY
	jal SOM1
	jal FIM

#==================================================

LEVEL1: bg_level1
#==================================================

FIM:	li a7,10		# syscall de exit
	ecall
#==================================================

HARRY:
	li a0,1
	li a1,160
	li a2,120	
	barrel_print a0,a1,a2

SOM1:	sound_game_over
