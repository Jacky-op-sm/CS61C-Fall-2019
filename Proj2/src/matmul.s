.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 125.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 126.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 127.
# =======================================================
matmul:

    # Error checks
    li t0, 1
    # dimensions of m0 should be >= 1
    blt a1, t0, exit_125
    blt a2, t0, exit_125
    # dimensions of m1 should be >= 1
    blt a4, t0, exit_125
    blt a5, t0, exit_125
    # columns of m0 must be equal to rows of m1
    bne a2, a4, mismatched_dimensions

    # Prologue
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)   
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)	
    sw ra, 36(sp)


    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s7, a5	# store a5
    mv s8, a6

    mv s4, x0	# teperary virable 
    mv s5, x0	# i - s5 : iterater for rows
    mv s6, x0	# j - s6 : iterater for columns

outer_loop_start:
	bge s5, s1, outer_loop_end


inner_loop_start:
	bge s6, s7, inner_loop_end
	mul t0, s5, s7	# t0 : position of target d Matrix
	add t0, t0, s6
	slli t0, t0, 2
	add t0, t0, s8

	mv t1, x0	# t1 : an iterater for m1, advance 1 / each inner loop
	slli t1, s6, 2
	add t1, s3, t1

	addi sp, sp, -4		# t0 : may change by calling subrouteen
	sw t0, 0(sp)

	# Call subrouteen of dot
	mv a0, s0
	mv a1, t1
	mv a2, s2
	li a3, 1
	mv a4, s7
	jal ra, dot

	# Restore t0
	lw t0, 0(sp)
	addi sp, sp, 4

	# Store the calculated value in position t0
	sw a0, 0(t0)

	# Update Inner loop

	addi s6, s6, 1	# Update index j - s6
	j inner_loop_start

inner_loop_end:
	# Update outer loop
	addi s5, s5, 1	# Update index i - s5
	mv s6, x0		# Reset index j - s6 to 0
	slli s4, s2, 2 
	add s0, s0, s4	# m0 should advance one row / each outer loop
	j outer_loop_start


outer_loop_end:


    # Epilogue
        
    lw s0, 0(sp)
    lw s1, 4(sp)   
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)	
    lw ra, 36(sp)
    addi sp, sp, 40
  
    jr ra

exit_125:
	li a1, 125
	jal exit2 


exit_126:
	li a1, 126
	jal exit2 

mismatched_dimensions:
    li a1 127
    jal exit2    
