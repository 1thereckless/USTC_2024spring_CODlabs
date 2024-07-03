li t0,1
li t1,1
li t2,1
addi x2,x2,-2
bge x0,x2,end
L1:
add t2,t0,t1
mv t0,t1
mv t1,t2
addi x2,x2,-1
bnez x2,L1
end:
mv x3,t2
