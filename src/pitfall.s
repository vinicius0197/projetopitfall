#########################################################
#  OAC 					  		#
#  Grupo 6				  		#
#########################################################

.data
INTRO: .string "images/intro.bin"
SCENA: .string "images/scenary.bin"
STAND: .string "images/harry/jump1.bin"

.include "harry.s"

.text

MAIN:
	#jal LOADSCREEN
	#jal BLACKSCREEN
	jal LEVEL1
	jal HARRY
	jal FIM

LOADSCREEN:
# SHOW PSEUDO LOADSCREEN
	la a0,INTRO# Endere�o da string do nome do arquivo
	li a1,0		# Leitura
	li a2,0		# bin�rio
	li a7,1024		# syscall de open file
	ecall			# retorna em $v0 o descritor do arquivo

	mv t0,a0		# salva o descritor em $t0
# Le o arquivos para a memoria VGA
	mv a0,t0		# $a0 recebe o descritor
	li a1,0xFF000000	# endereco de destino dos bytes lidos
	li a2,76800		# quantidade de bytes
	li a7,63		# syscall de read file
	ecall			# retorna em $v0 o numero de bytes lidos
#Fecha o arquivo
	mv a0,t0		# $a0 recebe o descritor
	li a7,57		# syscall de close file
	ecall			# retorna se foi tudo Ok
# WAIT 2 seconds
	li a0 2000
	li a7 32
	ecall
	ret
#==================================================

BLACKSCREEN:
	li t1,0xFF000000	# endereco inicial da Memoria VGA
	li t2,0xFF012C00	# endereco final
	li t3,0x00000000	# cor vermelho|vermelho|vermelhor|vermelho
LOOP1: 	beq t1,t2,END1	# Se for o �ltimo endere�o ent�o sai do loop
	sw t3,0(t1)		# escreve a word na mem�ria VGA
	addi t1,t1,4		# soma 4 ao endere�o
	j LOOP1			# volta a verificar
END1:
	ret
#==================================================

LEVEL1:
	la a0,SCENA 		# endereco da string do nome do arquivo
	li a1,0			# modo leitura
	li a2,0			# binario
	li a7,1024		# syscall de open file
	ecall			# retorna em $v0 o descritor do arquivo

	mv t0,a0		# salva o descritor em $t0

# Le o arquivos para a memoria VGA
	mv a0,t0		# $a0 recebe o descritor
	li a1,0xFF000000	# endereco de destino dos bytes lidos
	li a2,76800		# quantidade de bytes
	li a7,63		# syscall de read file
	ecall			# retorna em $v0 o numero de bytes lidos

#Fecha o arquivo
	mv a0,t0		# $a0 recebe o descritor
	li a7,57		# syscall de close file
	ecall			# retorna se foi tudo Ok
	ret
#==================================================

FIM:	li a7,10		# syscall de exit
	ecall
#==================================================

HARRY:
	harry_print 1,160,120
