loadi 1 0x01    // r1 = 1
loadi 2 0x02    // r2 = 2
loadi 3 0x03    // r3 = 3
loadi 4 0x05    // r4 = 5
swd 4 1 // store 5 in memory[1] => expect a cold miss (21 clock cycles)
swd 4 2 // store 5 in memory[2] => expect a cold miss (21 clock cycles)
swd 4 3 // store 5 in memory[3] => expect a cold miss (21 clock cycles)