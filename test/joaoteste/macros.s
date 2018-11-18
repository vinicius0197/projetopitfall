
.macro M_SetEcall(%label)
 	la t0,%label		# carrega em t0 o endereço base das rotinas do sistema ECALL
 	csrrw zero,5,t0 	# seta utvec (reg 5) para o endereço t0
 	csrrsi zero,0,1 	# seta o bit de habilitação de interrupção em ustatus (reg 0)
 .end_macro
