/*
 * cpu.v
 * Desc: CPU implementation with minimal instructions
 * Authors: M. S. Peeris <e19275@eng.pdn.ac.lk>,
 *          A. P. T. T. Perera <e19278@eng.pdn.ac.lk>
 * Group: 41
 * Last Modified: 31/05/2023
 */   

`include "alu.v"
`include "register.v"

module cpu(
    // declare ports
    output[31:0] PC, // 32-bit program counter value
    input[31:0] INSTRUCTION, // 32-bit instruction value
    input CLK,
    input RESET
);

    reg WRITEENABLE; // write enable signal to register file 
    reg MUX_SEL_NEG; // mux select signal to chose between immediate value or register value for alu
    reg MUX_SEL_IMM; // mux select signal to chose between original register or negated value for alu sub instruction
    reg[7:0] ALUIN1, ALUIN2; // alu input registers
    reg[2:0] ALUOP; // alu opcode
    
    // Decode opcode and set control signals
    always @ (INSTRUCTION[31:24])
    begin
        case (INSTRUCTION[31:24])
            // 0 - loadi
            0:  begin
                    ALUOP <= #1 0;
                    MUX_SEL_IMM <= #1 1;
                    WRITEENABLE <= #1 1; 
                end
            // 1 - mov
            1:  begin
                    ALUOP <= #1 0;
                    MUX_SEL_IMM <= #1 0;
                    MUX_SEL_NEG <= #1 0;
                    WRITEENABLE <= #1 1; 
                end
            // 2 - Add
            2:  begin
                    ALUOP <= #1 1;
                    MUX_SEL_NEG <= #1 0;
                    MUX_SEL_IMM <= #1 0;
                    WRITEENABLE <= #1 1;
                end
            // 3 - Sub
            3:  begin
                    ALUOP <= #1 1;
                    MUX_SEL_NEG <= #1 1;
                    MUX_SEL_IMM <= #1 0;
                    WRITEENABLE <= #1 1;
                end
            // 4 - And
            4:  begin
                    ALUOP <= #1 2;
                    MUX_SEL_NEG <= #1 0;
                    MUX_SEL_IMM <= #1 0;
                    WRITEENABLE <= #1 1;
                end
            // 5 - Or
            5:  begin
                    ALUOP <= #1 3;
                    MUX_SEL_NEG <= #1 0;
                    MUX_SEL_IMM <= #1 0;
                    WRITEENABLE <= #1 1;
                end
        endcase
    end   

    // initialize register module
    wire[7:0] WRITEDATA, REGOUT1, REGOUT2;
    reg_file cpu_reg_file(
        WRITEDATA, REGOUT1, REGOUT2, 
        INSTRUCTION[18:16], // INSTRUCTION[23:16] 8 bit rd address but uses only last 3 bits for 8x8 register address 
        INSTRUCTION[10:8],  // INSTRUCTION[15:8] 8 bit rt address but uses only last 3 bits for 8x8 register address
        INSTRUCTION[2:0],   // INSTRUCTION[7:0] 8 bit rs address but uses only last 3 bits for 8x8 register address
        WRITEENABLE, CLK, RESET
    );

    // reg to store 2s complement or imm value for the alu input 2
    reg[7:0] TEMP_REG;

    always @ (MUX_SEL_NEG, REGOUT2)
    begin
        if (MUX_SEL_NEG)
            TEMP_REG <= #1 (~REGOUT2) + 1;
        else
            TEMP_REG <= REGOUT2;
    end
    
    always @ (MUX_SEL_IMM, INSTRUCTION[7:0], TEMP_REG)
    begin
        if (MUX_SEL_IMM)
            ALUIN2 <= INSTRUCTION[7:0];
        else
            ALUIN2 <= TEMP_REG;
    end

    always @ (REGOUT1)
        ALUIN1 = REGOUT1;

    // initialize alu module
    alu cpu_alu(
        ALUIN1, 
        ALUIN2, 
        ALUOP, 
        WRITEDATA
    );

    // declare register to hold pc value and calculated next pc value
    reg[31:0] PC_REG, NEXT_PC_REG;
    assign PC = PC_REG;

    // update pc at each clock edge
    always @ (posedge CLK)
        #1 PC_REG = NEXT_PC_REG;

    // set pc to reset asynchronously at high reset signal
    always @ (RESET)
    begin
        if (RESET == 1)
        begin
            PC_REG = 0;
            NEXT_PC_REG = 0;
        end
    end

    // increment next pc after pc update
    always @ (PC_REG)
        #1 NEXT_PC_REG = NEXT_PC_REG + 4;

endmodule
