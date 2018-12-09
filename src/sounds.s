.text

.macro sound_jump ()
	li	a0, 66
	li	a1, 150
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 78
	li	a1, 100
	li	a2, 1
	li	a3, 127
	li	a7, 33
	ecall
	ret
.end_macro

.macro sound_gold ()
	li	a0, 90
	li	a1, 250
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 85
	li	a1, 400
	li	a2, 1
	li	a3, 127
	li	a7, 33
	ecall
	ret
.end_macro

.macro sound_hit ()
	li	a0, 30
	li	a1, 250
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 56
	li	a1, 100
	li	a2, 7
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 0
	li	a1, 300
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 40
	li	a1, 250
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 66
	li	a1, 100
	li	a2, 7
	li	a3, 127
	li	a7, 33
	ecall
	ret
.end_macro

.macro sound_next_level ()
	li	a0, 50
	li	a1, 300
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 55
	li	a1, 250
	li	a2, 2
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 60
	li	a1, 300
	li	a2, 3
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 55
	li	a1, 250
	li	a2, 1
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 60
	li	a1, 300
	li	a2, 2
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 65
	li	a1, 250
	li	a2, 3
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 70
	li	a1, 300
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 75
	li	a1, 250
	li	a2, 2
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 75
	li	a1, 300
	li	a2, 3
	li	a3, 127
	li	a7, 31
	ecall
	ret
.end_macro

.macro sound_game_over ()
	li	a0, 68
	li	a1, 200
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 48
	li	a1, 400
	li	a2, 3
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 58
	li	a1, 200
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 38
	li	a1, 400
	li	a2, 3
	li	a3, 127
	li	a7, 33
	ecall
	li	a0, 58
	li	a1, 100
	li	a2, 1
	li	a3, 127
	li	a7, 31
	ecall
	li	a0, 28
	li	a1, 600
	li	a2, 3
	li	a3, 127
	li	a7, 33
	ecall
	ret
.end_macro