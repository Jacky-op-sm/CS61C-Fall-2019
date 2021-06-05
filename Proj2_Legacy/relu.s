.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 is the pointer to the array
#	a1 is the # of elements in the array
# Returns:
#	None
# ==============================================================================
relu:
    # Prologue
    mv t0, x0	#t0 is a int iterater

loop_start:
	beq t0, a1, loop_end
	j loop_continue

loop_continue:
	slli t1, t0, 2
    add t1, t1, a0
    lw t2, 0(t1)
    blt t2, x0, ReLU

save_word:
    sw t2, 0(t1)
    addi t0, t0, 1
    j loop_start

ReLU:
	mv t2, x0    
	j save_word

loop_end:

    # Epilogue
	ret
