#########################################################
#  Programa de exemplo de uso do Bitmap Display Tool   	#
#  OAC Abril 2018			  		#
#  Marcus Vinicius Lamar		  		#
#########################################################
#
# Cuidar que o arquivo display.bin deve estar no mesmo diret�rio do Rars!
# Use o programa paint.net (baixar da internet) para gerar o arquivo .bmp de imagem 320x240 e 24 bits/pixel
# para ent�o usar o programa bmp2oac.exe para gerar o arquivo .bin correspondente

.data
INTRO: .string "images/intro.bin"
SCENA: .string "images/scenary.bin"
STAND: .string "images/standing.bin"

.text

MAIN:
	jal LOADSCREEN
	jal BLACKSCREEN
	jal BEGIN
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

BEGIN:
	la a0,SCENA # Endere�o da string do nome do arquivo
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
	ret
#==================================================

FIM:	li a7,10		# syscall de exit
	ecall
#==================================================

HARRY:
	li t1,0xFF000000	# endereco inicial da Memoria VGA
	li t2,0xFF012C00	# endereco final
	li t3,0x00000000	# cor vermelho|vermelho|vermelhor|vermelho
	li t0,4
	li t4,60
LOOP2: 	beq t1,t2,END2	# Se for o �ltimo endere�o ent�o sai do loop
	beq t0,t4,BREAKLINE
	addi t0,t0,4
	sw t3,0(t1)		# escreve a word na mem�ria VGA
	addi t1,t1,4		# soma 4 ao endere�o
	j LOOP2			# volta a verificar
BREAKLINE:
	li t0,4
	addi t1,t1,1220
	j LOOP2
END2:
	ret