.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 112.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 113.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 114.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)	# store the file describor
    sw ra, 20(sp)


    # Save the copy of inputs
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)

    # Call fopen
    mv a1, s0
    li a2, 1    # Write mode : 1
    jal ra, fopen

    # CHECK 1: FILE OPEN
    li t0, -1
    beq a0, t0, file_open_error

    # Now the returned a0 should be file describor
    mv s4, a0   # store the file describor to s4

    # Write rows into file
    mv a1, s4
    mv a2, sp
    li a3, 1
    li a4, 4
    jal ra, fwrite

    # CHECK 2: FILE WRITE ROW
    li t0, 1    
    blt a0, t0, file_write_error
    addi sp, sp, 4

    # Write columns into file
    mv a1, s4
    mv a2, sp
    li a3, 1
    li a4, 4
    jal ra, fwrite

    # CHECK 3: FILE WRITE COLLUM
    li t0, 1
    blt a0, t0, file_write_error
    addi sp, sp, 4

    # Write matrix into file
    mv a1, s4
    mv a2, s1
    mul t0, s2, s3
    mv a3, t0
    li a4, 4
    jal ra, fwrite

    # CHECK 4: FILE WRITE MATRIX
    mul t0, s2, s3
    blt a0, t0, file_write_error   

    # File close
    mv a1, s4
    jal ra, fclose
    # CHECK 4: FILE CLOSE
    bne a0, x0, file_close_error 

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)	# store the file describor
    lw ra, 20(sp)
    addi sp, sp, 24

    jr ra


file_open_error:
    li a1 112
    jal exit2

file_write_error:
    li a1 113
    jal exit2

file_close_error:
    li a1 114
    jal exit2