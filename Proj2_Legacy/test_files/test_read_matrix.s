.import ../read_matrix.s
.import ../utils.s

.data
file_path: .asciiz "./test_input.bin"

.text
main:
	# Malloc two 4 bytes integer
	li a0, 4
	jal ra, malloc 
	mv s0, a0

	li a0, 4
	jal ra, malloc 
	mv s1, a0
    # Read matrix into memory
    la a0, file_path
    mv a1, s0
    mv a2, s1
    jal ra, read_matrix

    # Now the returned a0 is a pointer to a matrix
    # Print out elements of matrix
    lw a1, 0(s1)
    lw a2, 0(s2)
    jal ra, print_int_array

    # Terminate the program
    addi a0, x0, 10
    ecall