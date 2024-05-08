/*
 * alu.v
 * Desc: Simple 8-bit ALU
 * Authors: M. S. Peeris <e19275@eng.pdn.ac.lk>,
 *          A. P. T. T. Perera <e19278@eng.pdn.ac.lk>
 * Group: 41
 * Last Modified: 31/05/2023
 */   

/*
// stimulus block
module testbench;
    
    // declare test registers
    reg[7:0] DATA1, DATA2;
    reg[2:0] SELECT;
    wire[7:0] OUTPUT;

    // declare test alu
    alu TESTALU(DATA1, DATA2, SELECT, OUTPUT);

    initial
    begin
        $monitor("DATA1: %d, DATA2: %d, SELECT: %d, OUTPUT: %d, ", 
            DATA1, DATA2, SELECT, OUTPUT);
        $dumpfile("wavedata.vcd");
        $dumpvars(0, testbench);

        SELECT = 3'b000;
        DATA1 = 8'b0000_1000;
        DATA2 = 8'b0110_1000;
        #5 SELECT = 3'b001;
        #5 SELECT = 3'b010;
        #5 SELECT = 3'b011;
        #5 SELECT = 3'b111;
        #5 DATA2 = 8'b0110_1011;
        #5 SELECT = 3'b010;
        #5 DATA1 = 8'b0000_1100;
    end

endmodule
*/

// 8-bit ALU
module alu(
    // declare ports
    input [7:0] DATA1, DATA2,
    input [2:0] SELECT,
    output [7:0] OUTPUT,
    output ZERO  
);
    
    // declare register to store computed value after delay
    reg [7:0] RESULT;

    // implement ALU functionality
    always @ (DATA1, DATA2, SELECT)
    begin
        case (SELECT)
            // 000 - Forward
            3'b000: #1 RESULT = DATA2;
            // 001 - Add
            3'b001: #2 RESULT = DATA1 + DATA2;
            // 010 - And
            3'b010: #1 RESULT = DATA1 & DATA2;
            // 011 - Or
            3'b011: #1 RESULT = DATA1 | DATA2;
            // 1xx - Reserved
            default: RESULT = 8'bxxxx_xxxx;
        endcase
    end   

    // assign computed value to output port
    assign OUTPUT = RESULT;

    // Implement flag for branch if equal (BEQ) functionality
    reg ZERO_REG;

    always @ (RESULT)
    begin
        if (RESULT == 0)
            ZERO_REG = 1;
        else
            ZERO_REG = 0;
    end

    assign ZERO = ZERO_REG;

endmodule