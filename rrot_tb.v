// Testbench to test right rotater module of the alu
`include "alu.v"

module testbench;
    
    // declare test registers
    reg signed[7:0] DATA1, DATA2;
    wire signed[7:0] OUTPUT;

    // declare test alu
    m_rrotater rrotater(DATA1, DATA2, OUTPUT);

    initial
    begin
        $monitor("DATA1: %b, DATA2: %b, OUTPUT: %b", 
            DATA1, DATA2, OUTPUT);
        $dumpfile("wavedata.vcd");
        $dumpvars(0, testbench);

        DATA1 = 0;
        DATA2 = 0;
        #5 DATA1 = 136;
        DATA2 = 3;
    end
endmodule