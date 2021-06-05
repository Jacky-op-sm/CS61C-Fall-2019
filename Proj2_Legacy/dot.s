.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 is the pointer to the start of v0
#   a1 is the pointer to the start of v1
#   a2 is the length of the vectors
#   a3 is the stride of v0
#   a4 is the stride of v1
# Returns:
#   a0 is the dot product of v0 and v1
# =======================================================
dot:

    # Prologue
    mv t0, x0	# t0: an int iterater
    mv t5, x0 	# t5: sum of the dot product

loop_start:
	beq t0, a2, loop_end
	mul t1, t0, a3		# t1: index pointer for v0
	mul t2, t0, a4		# t2: index pointer for v1
	
	slli t1, t1, 2		# int: take 4 bytes
	slli t2, t2, 2

	add t1, t1, a0		# t1: element's address for v0
	add t2, t2, a1		# t2: element's address for v1

	lw t3, 0(t1)		# t3: element for v0 at index i
	lw t4, 0(t2)		# t4: element for v1 at index i

	mul t3, t3, t4		# finish dot product
	add t5, t5, t3		

	addi t0, t0, 1		# update the index
	j loop_start

loop_end:

    # Epilogue
    mv a0, t5

    jr ra
