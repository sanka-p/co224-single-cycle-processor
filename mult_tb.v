// Testbench to test multiplier module of the alu

`include "alu.v"

module testbench;
    
    // declare test registers
    reg signed[7:0] DATA1, DATA2;
    wire signed[7:0] OUTPUT;

    // declare test alu
    m_multiplier multiplier(DATA1, DATA2, OUTPUT);

    initial
    begin
        $monitor("DATA1: %d, DATA2: %d, OUTPUT: %d", 
            DATA1, DATA2, OUTPUT);
        $dumpfile("wavedata.vcd");
        $dumpvars(0, testbench);

        DATA1 = 0;
        DATA2 = 0;
        #5 DATA1 = 3;
        DATA2 = 5;
        #5 DATA1 = 10;
        DATA2 = -5;
        #5 DATA1 = -3;
        DATA2 = -5;
    end
endmodule