.import ../dot.s
.import ../utils.s

# Set vector values for testing
.data
vector0: .word 1 2 3 4 5 6 7 8 9
vector1: .word 1 2 3 4 5 6 7 8 9


.text
# main function for testing
main:
    # Load vector addresses into registers
    la s0 vector0
    la s1 vector1

    # Set vector attributes
    # Set length of vector
    addi s2 x0 9 # length: MAKE CHANGES HERE

    # Set stride for vector
    addi s3 x0 1 # stride for v0: MAKE CHANGES HERE
    addi s4 x0 1 # stride for v1: MAKE CHANGES HERE

    # Call dot function
    mv a0 s0
    mv a1 s1
    mv a2 s2
    mv a3 s3
    mv a4 s4
    jal ra, dot
    
    # Print integer result
    mv a1 a0
    jal ra print_int

    # Print newline
    li a1 '\n'
    jal ra print_char

    # Exit
    jal exit
