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
199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199

jump1: .word 20, 24
.byte 199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,27,27,27,27,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,94,94,94,94,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,94,94,94,94,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,94,94,199,199,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,107,107,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,107,107,107,107,107,107,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,25,25,25,25,25,25,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,25,25,199,199,25,25,199,199,199,199,199,
199,199,199,199,199,25,25,25,25,25,25,25,25,25,25,199,199,199,199,199,
199,199,199,199,199,25,25,199,199,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,25,25,199,199,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,25,25,199,199,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,25,25,25,25,199,199,199,199,199,199,199,
199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,199,




.text

.macro harry_print (%action, %x, %y)
	addi sp, sp, -4	# begin BACKGROUND
	sw ra, 0(sp)
# Define intervalo de print do boneco
	li t0,0xFF000000	# posicao inicial da tela
	li t6,320		# largura da tela
	mv t5,%y		# numero de linhas ate altura do boneco
	mul t4,%y,t6		# quantidade de linhas ate altura do boneco
	add t0,t0,t4		# adicona a posicao inicial do boneco
	mv t4,%x		# numero de colunas ate o boneco
	add t0,t0,%x		# adiciona posicao x a posicao inicial boneco (colunas)
	# ================================ variaveis t0=posicaoinicial t4=x t5=y t6=larguralinha

	add t1,zero,t0		# endereco final
	li t3,24		# altura
	mul t3,t6,t3		# altura do boneco
	add t1,t1,t3
	addi t1,t1,-8
	
	li t3,0			#tamanho da quebra de linha
	li t4,20
	la t6,jump1
	addi t6,t6,8

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
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
.end_macro
