# CS61CPU

Look ma, I made a CPU! Here's what I did:

-I finished all part A by my own!
-Task 1: ALU
	1. Except the mulh part, others are simple by employing the build-in block.
	2. The explanation of mulh part is stored in that sub-circuit file: the basic idea is to divide the unsigned number into 2 parts, (-A + B). And do the calculation manually.

-Task 2: Reg File
	1. The idea behind this is not complicated, but this part actually costs me most of time, because I moved the input and output bin but not release it!!! Therefore the test always fails and I can't find my bug is. Until I opened the reference file written by others, did I release there was something wrong with my input pin.
	2. Besides the little accident mentioned above, it's quite smooth.

-Task 3: Addi
	1. At first basically I have no idea how to implement. But I find the guide is qute useful; it helps to reflect on the right idea and thus make implementation quite natural. Therefore, this part is smooth as well.
	2. Here pipeline has only 2 stages. So only need one of the register to "back-up" .
