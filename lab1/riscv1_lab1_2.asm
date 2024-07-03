li x2,80
li t0,1
li t1,1
li t2,1
addi x2,x2,-2
bge x0,x2 end
L1:
addi x2,x2,-1
add t2,t0,t1
add a3,a1,a2
bge t2,t0,L2
slli t2,t2,1
srli t2,t2,1
addi a3,a3,1
L2:
mv t0,t1
mv t1,t2
mv a1,a2
mv a2,a3
bnez x2,L1
end:
mv x3,a3
srli x3,x3,1
mv x4,a3
slli x4,x4,31
add x4,x4,t2
