# testa a excecao de instru��o inv�lida

.include "../SYSTEMv1.s"

.text
MAIN:	la $t0,MAIN
	la $t1,0xFFFFFFFF  # instru��o inv�lida
	sw $t1,24($t0)
	nop
	nop
	nop		  #local da instru��o inv�lida
	nop

	li $v0,10
	syscall
