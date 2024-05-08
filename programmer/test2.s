loadi 1 0x01    // r1 = 1
loadi 2 0x05    // r2 = 5
loadi 3 0x21    // r3 = 33
loadi 4 0x05    // r4 = 4
swd 1 2 // store 5 in memory[1] => expect a cold miss (21 clock cycles)
swd 1 3 // store 33 in memory[1] => expect a write hit
swd 3 1 // store 1 in memory[33] => expect a dirty write miss (42 clock cycles) 
lwd 1 1 // r1 = 33 => read hit
lwd 4 3 // r4 = memory[33] = 1 => read hit
lwd 4 1 // r4 = memory[33] = 1 => read hit