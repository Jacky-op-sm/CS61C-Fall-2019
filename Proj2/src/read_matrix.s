.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 116.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 117.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 118.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 119.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28

    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    # Virables needed
    sw s3, 12(sp)   # store the file describor
    sw s4, 16(sp)   # store the returned memory after malloc
    sw s5, 20(sp)   # store total bytes for the matrix
    sw ra, 24(sp)
    
    # Store the orginal Arguments
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # Call fopen
    mv a1, s0
    li a2, 0    # Read mode : 0
    jal ra, fopen

    # CHECK 1: FILE OPEN
    li t0, -1
    beq a0, t0, file_open_error

    # Now the returned a0 should be file describor
    mv s3, a0   # store the file describor to s3
    # Read the row
    mv a1, s3
    mv a2, s1
    li a3, 4
    jal ra, fread
    # CHECK 2: FILE READ
    li t0, 4
    bne a0, t0, file_read_error

    # Read the col
    mv a1, s3
    mv a2, s2
    li a3, 4
    jal ra, fread
    # CHECK 2: FILE READ
    li t0, 4
    bne a0, t0, file_read_error

    # Malloc memory for matrix
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul t0, t0, t1  # t0 : total number of the element

    slli t0, t0, 2  # t0 : total bytes for the matrix
    mv s5, t0       # s5 : store total bytes for the matrix
    mv a0, t0
    jal ra, malloc
    # CHECK 5: MALLOC 
    beq a0, x0, malloc_error

    # Now returned a0 is the space for matrix 
    mv s4, a0   # store the returned memory

    # Read the matrix
    mv a1, s3
    mv a2, s4
    mv a3, s5
    jal ra, fread
    # CHECK 3: FILE READ
    bne a0, s5, file_read_error


    # File close
    mv a1, s3
    jal ra, fclose
    # CHECK 4: FILE CLOSE
    bne a0, x0, file_close_error


    # Set return value
    mv a0, s4

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)   # store the file describor
    lw s4, 16(sp)   # store the returned memory after malloc
    lw s5, 20(sp)   # store total bytes for the matrix
    lw ra, 24(sp)
    addi sp, sp, 28

    jr ra


malloc_error:
    li a1 116
    jal exit2

file_open_error:
    li a1 117
    jal exit2

file_read_error:
    li a1 118
    jal exit2

file_close_error:
    li a1 119
    jal exit2