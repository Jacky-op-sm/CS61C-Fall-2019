addi t0, x0, 1
add t0, t0, t0
mul t0, t0, t0
sub t1, t0, x0
sub s0, t1, t0
addi t2, x0, 1
srl t0, t0, t2
slt s1, t2, t0
slt a0, s1, t2
xor t0, t0, t2
divu s0, t1, t0
sll t0, t1, t1
or t2, t2, t1
remu t0, t0, t1
and t0, t0, t2