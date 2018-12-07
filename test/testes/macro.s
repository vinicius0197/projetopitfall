######### Verifica se eh a DE1-SoC ###############
.macro DE1(%salto)
	li tp, 0x10008000			# carrega tp = 0x10008000
	bne gp,tp,%salto
.end_macro

######### Seta o endereco UTVEC ###############
.macro M_SetEcall(%label)
 	la t0,%label		# carrega em t0 o endereço base das rotinas do sistema ECALL
 	csrrw zero,5,t0 	# seta utvec (reg 5) para o endereço t0
 	csrrsi zero,0,1 	# seta o bit de habilitação de interrupção em ustatus (reg 0)
 	la tp,UTVEC		# caso nao tenha csrrw apenas salva o endereco %label em UTVEC
 	sw t0,0(tp)
 .end_macro

######### Chamada de Ecall #################
.macro M_Ecall
	DE1(NotECALL)
 	ecall
 	j FimECALL			
NotECALL: la tp,UEPC	
	la t6,FimECALL	# endereco após o ecall
	sw t6,0(tp)	# salva UEPC
	lw tp,4(tp)	# UTVEC
	jalr zero,tp,0	# chama UTVEC
FimECALL: nop
 .end_macro
 

######### Chamada de Uret #################
.macro M_Uret
	DE1(NotURET)
 	uret			# tem uret? só retorna
NotURET: la tp,UEPC		# nao tem uret
	lw tp,0(tp)		# carrega o endereco UEPC
	jalr zero,tp,0		# pula para UEPC
 .end_macro
 
 
