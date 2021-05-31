#loop a0 times and each loop multiple t0 by 2
addi a0, x0, 10
addi t0, x0, 2
start:
	beq a0, x0, end
loop:
	slli t0, t0, 1
	addi a0, a0, -1
	beq x0, x0, start
end:
	add a0, x0, t0