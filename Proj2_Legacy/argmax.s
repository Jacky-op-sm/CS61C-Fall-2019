.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 is the pointer to the start of the vector
#	a1 is the # of elements in the vector
# Returns:
#	a0 is the first index of the largest element
# =================================================================
argmax:

    # Prologue
    mv t0, x0	#t0 is a int iterater
    lw t3, 0(a0) 	#t3: max element so far
    mv t4, x0 	#t4: index of the max element

loop_start:
	beq t0, a1, loop_end
	j loop_continue

loop_continue:
	slli t1, t0, 2
    add t1, t1, a0
    lw t2, 0(t1)
    bge t2, t3, change

after_ward:
    addi t0, t0, 1
    j loop_start

change:
	mv t3, t2
	mv t4, t0    
	j after_ward

loop_end:

	mv a0, t4
    # Epilogue
	jr ra




