.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 121.
    # - If malloc fails, this function terminates the program with exit code 116 (though we will also accept exit code 122).
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Prologue
    ebreak
    addi sp, sp, -44

    # For orginal Arguments
    sw s0, 0(sp)    # argc
    sw s1, 4(sp)    # argv  
    sw s2, 8(sp)    # print select

    # For returned matrix
    sw s3, 12(sp)   # M0
    sw s4, 16(sp)   # M1
    sw s5, 20(sp)   # INPUT
    # For 
    sw s6, 24(sp)   # Space for immediate matrix
    sw s7, 28(sp)   # Space for final matrix
    sw s8, 32(sp)   # Store the final index of largest element
    sw s9, 36(sp)   # Store the row, col info of matrices
    sw ra, 40(sp)

    # Store the orginal Arguments
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # Check 1: argc should be 5
    li t0, 5
    bne s0, t0, args_number_error


	# =====================================
    # LOAD MATRICES
    # =====================================
    
    # Space for row, col info of m0, m1, input_m MATRICES
    li t0, 6
    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc

    # CHECK 2: MALLOC 
    beq a0, x0, malloc_error

    # Now returned a0 is the space for row, col info of matrices
    mv s9, a0

    # Load pretrained m0
    li t0, 1
    slli t0, t0, 2
    add t0, t0, s1  
    lw t1, 0(t0)    # t1 : pointer to <M0_PATH>

    mv a0, t1
    addi t3, s9, 0
    mv a1, t3
    addi t4, s9, 4
    mv a2, t4
    jal ra, read_matrix

    # Now a0 is the pointer to the matrix m0 in memory
    mv s3, a0   # Save m0 to s3

    # Load pretrained m1
    li t0, 2
    slli t0, t0, 2
    add t0, t0, s1  
    lw t1, 0(t0)    # t1 : pointer to <M1_PATH>

    mv a0, t1
    addi t3, s9, 8
    mv a1, t3
    addi t4, s9, 12
    mv a2, t4
    jal ra, read_matrix

    # Now a0 is the pointer to the matrix m1 in memory
    mv s4, a0   # Save m1 to s4



    # Load input matrix
    li t0, 3
    slli t0, t0, 2
    add t0, t0, s1  
    lw t1, 0(t0)    # t1 : pointer to <INPUT_PATH>

    mv a0, t1
    addi t3, s9, 16     # rows of input_m
    mv a1, t3
    addi t4, s9, 20     # cols of input_m
    mv a2, t4
    jal ra, read_matrix

    # Now a0 is the pointer to the matrix input in memory
    mv s5, a0   # Save input matrix to s5


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # Malloc memory for immediate matrix multiply result
    lw t0, 0(s9)    # t0 : rows of m0
    lw t1, 20(s9)   # t1 : collum of input_m
    mul t0, t0, t1

    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc

    # CHECK 2: MALLOC 
    beq a0, x0, malloc_error

    # Now returned a0 is the space for immediate matrix 
    mv s6, a0

    # 1. LINEAR LAYER:    m0 * input
    mv a0, s3       # m0
    lw a1, 0(s9)    # rows of m0
    lw a2, 4(s9)    # cols of m0
    mv a3, s5       # input_m
    lw a4, 16(s9)   # rows of input_m
    lw a5, 20(s9)   # cols of input_m
    mv a6, s6       # immediate matrix
    jal ra, matmul

    # Now s6 is a pointer to immediate matrix of value m0 * input

    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    lw t0, 0(s9)    # t0 : rows of m0
    lw t1, 20(s9)   # t1 : collumn of input_m
    mul t0, t1, t0

    mv a0, s6
    mv a1, t0
    jal relu 

    # Now s6 is a pointer to immediate matrix of value ReLU(m0 * input)

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    # Malloc memory for final result matrix
    lw t0, 8(s9)     # t0 : rows of m1
    lw t1, 20(s9)    # t1 : collum of input_m
    mul t0, t0, t1

    slli t0, t0, 2
    mv a0, t0
    jal ra, malloc

    # CHECK 3: MALLOC for final result matrix
    beq a0, x0, malloc_error

    # Now returned a0 is the space for final result matrix
    mv s7, a0   # Store it to s7

    mv a0, s4       # m1
    lw a1, 8(s9)    # rows of m1
    lw a2, 12(s9)   # cols of m1
    mv a3, s6       # immediate matrix  
    lw a4, 0(s9)    # rows of immediate matrix 
    lw a5, 20(s9)   # cols of immediate matrix 
    mv a6, s7       # final result matrix
    jal ra, matmul

    # Now returned s7 is a pointer to final result matrix of value m1 * ReLU(m0 * input)

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    # Load <OUTPUT_PATH>
    li t0, 4
    slli t0, t0, 2
    add t0, t0, s1  
    lw t1, 0(t0)    # t1 : pointer to <OUTPUT_PATH>

    mv a0, t1
    mv a1, s7

    lw t3, 8(s9)    # t3 : rows of final result matrix
    lw t4, 20(s9)   # t4 : cols of final result matrix
    mv a2, t3
    mv a3, t4
    jal write_matrix

    # Now returned s7 is still a pointer to final result matrix of value m1 * ReLU(m0 * input)

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    lw t3, 8(s9)    # t3 : rows of final result matrix
    lw t4, 20(s9)   # t4 : cols of final result matrix
    mul t3, t3, t4

    mv a0, s7
    mv a1, t3
    jal ra, argmax

    # Now returned a0 is the first index of the largest element in s7
    mv s8, a0


    # Print classification
    bne s2, x0, done
    mv a1, s8
    jal ra, print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal ra, print_char   

done:
    
    # Free the space for rows, cols info of matrices
    mv a0, s9
    jal ra, free

    # Free the space for malloc matrices m0, m1, input_m, immediate, final, index
    mv a0, s3
    jal ra, free

    mv a0, s4
    jal ra, free

    mv a0, s5
    jal ra, free

    mv a0, s6
    jal ra, free

    mv a0, s7
    jal ra, free

    mv a0, s8
    jal ra, free
    

    # Epilogue
    lw s0, 0(sp)    # argc
    lw s1, 4(sp)    # argv  
    lw s2, 8(sp)    # print select

    # For returned matrix
    lw s3, 12(sp)   # M0
    lw s4, 16(sp)   # M1
    lw s5, 20(sp)   # INPUT
    # For 
    lw s6, 24(sp)   # Space for immediate matrix
    lw s7, 28(sp)   # Space for final matrix
    lw s8, 32(sp)   # Store the final index of largest element
    lw s9, 36(sp)
    lw ra, 40(sp)
    addi sp, sp, 44
    ret


malloc_error:
    li a1 116
    jal exit2

args_number_error:
    li a1 121
    jal exit2