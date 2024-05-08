/*
 * alu.v
 * Desc: Simple 8-bit ALU
 * Authors: M. S. Peeris <e19275@eng.pdn.ac.lk>,
 *          A. P. T. T. Perera <e19278@eng.pdn.ac.lk>
 * Group: 41
 * Last Modified: 09/06/2023
 */   

// `timescale 1s/100ms

/*
// stimulus block
module testbench;
    
    // declare test registers
    reg[7:0] DATA1, DATA2;
    reg[2:0] SELECT;
    wire[7:0] OUTPUT;
    wire ZERO;

    // declare test alu
    alu TESTALU(DATA1, DATA2, SELECT, OUTPUT, ZERO);

    initial
    begin
        $monitor("DATA1: %b, DATA2: %b, SELECT: %b, OUTPUT: %b, ", 
            DATA1, DATA2, SELECT, OUTPUT);
        $dumpfile("wavedata.vcd");
        $dumpvars(0, testbench);

        SELECT = 3'b101;
        DATA1 = 8'b0000_1000;
        DATA2 = 8'b1000_0010;
        #5 SELECT = 3'b001;
        // #5 SELECT = 3'b010;
        // #5 SELECT = 3'b011;
        // #5 SELECT = 3'b111;
        // #5 DATA2 = 8'b0110_1011;
        // #5 SELECT = 3'b010;
        // #5 DATA1 = 8'b0000_1100;
    end

endmodule
*/

// 8-bit ALU
module alu(
    // declare ports
    input [7:0] DATA1, DATA2,
    input [2:0] SELECT,
    output [7:0] OUTPUT,
    output ZERO,
    input SHIFT_DIRECTION 
);
    
    // declare register to store computed value after delay
    reg [7:0] RESULT;
    // declare registers to store computed values from bonus modules 
    wire [7:0] SLL_REG, SLR_REG, MULT_REG, SAR_REG, RROT_REG;

    // instantiate bonus modules
    m_logic_lshifter logic_lshifter(DATA1, DATA2, SLL_REG);
    m_logic_rshifter logic_rshifter(DATA1, DATA2, SLR_REG);
    m_multiplier multiplier(DATA1, DATA2, MULT_REG);
    m_arith_rshifter arith_rshifter(DATA1, DATA2, SAR_REG);
    m_rrotater rrotater(DATA1, DATA2, RROT_REG);

    // implement ALU functionality
    always @ (DATA1, DATA2, SELECT, SLL_REG, SLR_REG, MULT_REG, SAR_REG, RROT_REG, SHIFT_DIRECTION)
    begin
        case (SELECT)
            // 000 - Forward
            3'b000: #1 RESULT = DATA2;
            // 001 - Add
            // 3'b001: #1.99 RESULT = DATA1 + DATA2;
            3'b001: #2 RESULT = DATA1 + DATA2;
            // 010 - And
            3'b010: #1 RESULT = DATA1 & DATA2;
            // 011 - Or
            3'b011: #1 RESULT = DATA1 | DATA2;
            // 100 - Mult
            3'b100: begin
                #2 RESULT = MULT_REG;
            end
            // 101 - Logical Shift Left and Right
            3'b101: begin
                case (SHIFT_DIRECTION)
                    1'b0: #1 RESULT = SLL_REG;
                    1'b1: #1 RESULT = SLR_REG;
                endcase    
            end 
            // 110 - Arithmetic Shift Right
            3'b110: #1 RESULT = SAR_REG;
            // 111 - Rotate
            3'b111: #1 RESULT = RROT_REG;
            default: RESULT = 8'bxxxx_xxxx;
        endcase
    end   

    // assign computed value to output port
    assign OUTPUT = RESULT;

    // Implement flag for branch if equal (BEQ) functionality
    reg ZERO_REG;

    always @ (RESULT)
    begin
        if (OUTPUT === 8'b00000000)
            ZERO_REG = 1;
        else
            ZERO_REG = 0;
    end

    assign ZERO = ZERO_REG;

endmodule

module m_logic_lshifter(
    input [7:0] OPERAND1, OPERAND2,
    output [7:0] OUTPUT
);
    reg[7:0] TEMP;
    assign OUTPUT = TEMP;

    always @ (OPERAND1, OPERAND2)
    begin
        // Shift bits to left and pad remaining bits with 0
        case (OPERAND2[3:0])
            0: TEMP = OPERAND1;
            1: TEMP = {OPERAND1[6:0], 1'b0};
            2: TEMP = {OPERAND1[5:0], 2'b0};
            3: TEMP = {OPERAND1[4:0], 3'b0};
            4: TEMP = {OPERAND1[3:0], 4'b0};
            5: TEMP = {OPERAND1[2:0], 5'b0};
            6: TEMP = {OPERAND1[1:0], 6'b0};
            7: TEMP = {OPERAND1[0], 7'b0};
            8: TEMP = {8'b0};
            default: TEMP = {8{1'b0}};
        endcase
    end
endmodule

module m_logic_rshifter(
    input [7:0] OPERAND1, OPERAND2,
    output [7:0] OUTPUT
);
    reg[7:0] TEMP;
    assign OUTPUT = TEMP;
    
    always @ (OPERAND1, OPERAND2)
    begin
        // Shift bits to right and pad remaining bits with 0
        case (OPERAND2[3:0])
            0: TEMP = OPERAND1;
            1: TEMP = {1'b0, OPERAND1[7:1]};
            2: TEMP = {2'b0, OPERAND1[7:2]};
            3: TEMP = {3'b0, OPERAND1[7:3]};
            4: TEMP = {4'b0, OPERAND1[7:4]};
            5: TEMP = {5'b0, OPERAND1[7:5]};
            6: TEMP = {6'b0, OPERAND1[7:6]};
            7: TEMP = {7'b0, OPERAND1[7]};
            8: TEMP = {8'b0};
            default: TEMP = {8{1'b0}};
        endcase
    end
endmodule

module m_arith_rshifter(
    input [7:0] OPERAND1, OPERAND2,
    output [7:0] OUTPUT
);
    reg[7:0] TEMP;
    assign OUTPUT = TEMP;
    
    always @ (OPERAND1, OPERAND2)
    begin
        // Shift bits to right and pad remaining bits with MSB
        case (OPERAND2[3:0])
            0: TEMP = OPERAND1;
            1: TEMP = {{1{OPERAND1[7]}}, OPERAND1[7:1]};
            2: TEMP = {{2{OPERAND1[7]}}, OPERAND1[7:2]};
            3: TEMP = {{3{OPERAND1[7]}}, OPERAND1[7:3]};
            4: TEMP = {{4{OPERAND1[7]}}, OPERAND1[7:4]};
            5: TEMP = {{5{OPERAND1[7]}}, OPERAND1[7:5]};
            6: TEMP = {{6{OPERAND1[7]}}, OPERAND1[7:6]};
            7: TEMP = {8{OPERAND1[7]}};
            8: TEMP = {8{OPERAND1[7]}};
            default: TEMP = {8'bx};
        endcase
    end
endmodule

module m_rrotater(
    input [7:0] OPERAND1, OPERAND2,
    output [7:0] OUTPUT
);
    reg[7:0] TEMP;
    assign OUTPUT = TEMP;
    
    always @ (OPERAND1, OPERAND2)
    begin
        case (OPERAND2 % 8)
            0: TEMP = OPERAND1;
            1: TEMP = {OPERAND1[6:0], OPERAND1[7]};
            2: TEMP = {OPERAND1[5:0], OPERAND1[7:6]};
            3: TEMP = {OPERAND1[4:0], OPERAND1[7:5]};
            4: TEMP = {OPERAND1[3:0], OPERAND1[7:4]};
            5: TEMP = {OPERAND1[2:0], OPERAND1[7:3]};
            6: TEMP = {OPERAND1[1:0], OPERAND1[7:2]};
            7: TEMP = {OPERAND1[0], OPERAND1[7:1]};
        endcase
    end
endmodule

module m_multiplier(
    input[7:0] MULTIPLICAND, MULTIPLIER,
    output reg[7:0] PRODUCT
);

    reg[7:0] INTERMEDIATE;

    always @ (MULTIPLICAND, MULTIPLIER)
    begin
        /*
        A bit-wise multiplication module, where each bit of the MULTIPLIER is individually multiplied 
        with the MULTIPLICAND and accumulated in the PRODUCT. i.e., for each bit of the MULTIPLIER, the corresponding 
        MULTIPLICAND is ANDed with the MULTIPLIER bit. The result is then left-shifted by the appropriate 
        number of bits, which is determined by the position of the MULTIPLIER bit. The resulting intermediate value is 
        added to the PRODUCT. This process is repeated for each bit of the MULTIPLIER.
        */
        PRODUCT = 0;    
        INTERMEDIATE = {{8{{8{MULTIPLIER[0]}} & MULTIPLICAND}}, {0{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{7{{8{MULTIPLIER[1]}} & MULTIPLICAND}}, {1{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{8{{8{MULTIPLIER[2]}} & MULTIPLICAND}}, {2{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{5{{8{MULTIPLIER[3]}} & MULTIPLICAND}}, {3{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{4{{8{MULTIPLIER[4]}} & MULTIPLICAND}}, {4{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{3{{8{MULTIPLIER[5]}} & MULTIPLICAND}}, {5{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{2{{8{MULTIPLIER[6]}} & MULTIPLICAND}}, {6{1'b0}}};
        PRODUCT += INTERMEDIATE;
        INTERMEDIATE = {{1{{8{MULTIPLIER[7]}} & MULTIPLICAND}}, {7{1'b0}}};
        PRODUCT += INTERMEDIATE;
    end
endmodule