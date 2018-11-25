.data
standing: .word 20, 24
.byte 199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,27,27,27,27,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,94,94,94,94,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,94,94,94,94,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,94,94,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,107,107,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,107,107,107,107,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,107,107,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,25,25,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,

.text

.macro harry_print (%action, %x, %y)
	la a0,%action # Endere�o da string do nome do arquivo
	li a1,0		# Leitura
	li a2,0		# bin�rio
	li a7,1024		# syscall de open file
	ecall			# retorna em $v0 o descritor do arquivo
	mv t0,a0		# salva o descritor em $t0
# Le o arquivos para a memoria VGA
	mv a0,t0		# $a0 recebe o descritor
	li a1,0xFF000000	# endereco de destino dos bytes lidos
	li a2,375		# quantidade de bytes
	li a7,63		# syscall de read file
	ecall			# retorna em $v0 o numero de bytes lidos
#Fecha o arquivo
	mv a0,t0		# $a0 recebe o descritor
	li a7,57		# syscall de close file
	ecall

# Define intervalo de print do boneco
	li t0,0xFF000000	# posicao inicial da tela
	li t6,320		# largura da tela
	li t5,%y		# numero de linhas ate altura do boneco
	mul t4,t5,t6		# quantidade de linhas ate altura do boneco
	add t0,t0,t4		# adicona a posicao inicial do boneco
	li t4,%x		# numero de colunas ate o boneco
	add t0,t0,t4		# adiciona posicao x a posicao inicial boneco (colunas)
	# ================================ variaveis t0=posicaoinicial t4=x t5=y t6=larguralinha
	
	add t1,zero,t0		# endereco final
	li t3,24		# altura
	mul t3,t6,t3		# altura do boneco
	add t1,t1,t3
	add t1,t1,t4
	
	li t3,0			#tamanho da quebra de linha
	li t4,20
	la t6,standing

LOOP2: 	bgt t0,t1,END2	# Se for o �ltimo endere�o ent�o sai do loop
	beq t3,t4,BREAKLINE
	lw t2,0(t6)
	sw t2,0(t0)
	addi t6,t6,4		# escreve a word na memoria VGA
	addi t0,t0,4
	addi t3,t3,4
	j LOOP2			# volta a verificar
BREAKLINE:
	li t3,0
	addi t5,t4,-320
	neg t5,t5
	add t0,t0,t5
	j LOOP2
END2:
	ret
.end_macro