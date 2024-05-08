// Assembly program to implement following loop in c
// for (int i = 4; i != 1; i--)
//      ;

loadi 0 0x01 // load 1 to r0
loadi 1 0x04 // load 4 to r1
beq 0x02 0 1 // if r0 and r1 are equal jump 3 instructions forward
sub 1 1 0    // r1 = r1 - r0
j 0xFD       // jump 3 instructions back