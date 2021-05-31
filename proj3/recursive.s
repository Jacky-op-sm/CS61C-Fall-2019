# loop a0 times and each loop multiple t0 by 2
# Recursive version
addi a0, x0, 10
addi t0, x0, 1
lui sp, 0xfffff
lui ra, 74565
addi ra, ra, 0

Recursive:
beq a0, x0, end
addi sp, sp, -4
sw ra, 0(sp)
addi a0, a0, -1
jal ra, Recursive
slli a0, a0, 1
lw ra, 0(sp)
addi sp, sp, 4
jr ra

end:
add a0, x0, t0
jalr x0, ra, 0