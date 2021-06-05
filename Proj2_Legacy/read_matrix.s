.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 is the pointer to string representing the filename
#   a1 is a pointer to an integer, we will set it to the number of rows
#   a2 is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 is the pointer to the matrix in memory
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28

    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    # Virables needed
    sw s3, 12(sp)	# store the file describor
    sw s4, 16(sp)	# store the returned memory after malloc
    sw s5, 20(sp)	# store total bytes for the matrix
    sw ra, 24(sp)
    
    # Store the orginal Arguments
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # Call fopen
    mv a1, s0
    li a2, 0 	# Read mode : 0
    jal ra, fopen

    # CHECK 1: FILE OPEN

    # Now the returned a0 should be file describor
    mv s3, a0	# store the file describor to s3
    # Read the row
    mv a1, s3
    mv a2, s1
    li a3, 4
    jal ra, fread

    # CHECK 2: FILE READ
    # Read the col
    mv a1, s3
    mv a2, s2
    li a3, 4
    jal ra, fread

    # CHECK 2: FILE READ

    # Malloc memory for matrix
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul t0, t0, t1	# t0 : total number of the element

    slli t0, t0, 2 	# t0 : total bytes for the matrix
    mv s5, t0		# s5 : store total bytes for the matrix
    mv a0, t0
    jal ra, malloc

    # Now returned a0 is the space for matrix 
    mv s4, a0	# store the returned memory

    # Read the matrix
    mv a1, s3
    mv a2, s4
    mv a3, s5
    jal ra, fread


    # File close
    mv a1, s3
    jal ra, fclose

    # Set return value
    mv a0, s4

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)	# store the file describor
    lw s4, 16(sp)	# store the returned memory after malloc
    lw s5, 20(sp)	# store total bytes for the matrix
    lw ra, 24(sp)
    addi sp, sp, 28

    jr ra

eof_or_error:
    li a1 1
    jal exit2
    