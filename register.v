/*
 * register.v
 * Desc: 8x8 register file
 * Authors: M. S. Peeris <e19275@eng.pdn.ac.lk>,
 *          A. P. T. T. Perera <e19278@eng.pdn.ac.lk>
 * Group: 41
 * Last Modified: 31/05/2023
 */   

`timescale 1ns/100ps

/*
// stimulus block
module testbench;

    // adapted from reg_file_tb.v that was provided
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
       
    initial
    begin 
        CLK = 1'b1;
        
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("wavedata.vcd");
		$dumpvars(0, testbench);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #4
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #6
        RESET = 1'b0;
        
        #2
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #7
        WRITEENABLE = 1'b0;
        
        #1
        READREG1 = 3'd2;
        
        #7
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #8
        WRITEENABLE = 1'b0;
        
        #8
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #8
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = -3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
endmodule
*/

// 8x8 register file
module reg_file(
    // declare ports
    input[7:0] IN, // 8 bit data input port
    output[7:0] OUT1, OUT2, // 8 bit data outport ports
    input[2:0] INADDRESS, // 3 bit input address port
    input[2:0] OUT1ADDRESS, OUT2ADDRESS, // 3 bit output address ports
    input WRITE, // write enable signal
    input CLK, // clock signal
    input RESET // register reset signal
);

    // Declare 8x8-bit register file
    reg[7:0] REGISTER[7:0];

    //==========OUTPUT REGISTER HANDLING==========

    // Declare output registers
    reg[7:0] OUT1REGISTER, OUT2REGISTER;

    // asynchronously read output registers
    always @ (OUT1ADDRESS, OUT2ADDRESS, REGISTER[OUT1ADDRESS], REGISTER[OUT2ADDRESS])
    begin
       OUT1REGISTER <= #2 REGISTER[OUT1ADDRESS];
       OUT2REGISTER <= #2 REGISTER[OUT2ADDRESS];
    end

    // Continously write output register values to output ports
    assign OUT1 = OUT1REGISTER;
    assign OUT2 = OUT2REGISTER;


    //==========INPUT REGISTER HANDLING==========

    // synchronously write to input register at positive edge of clock
    // when the WRITE signal is high
    always @ (posedge CLK)
    begin
        if (WRITE == 1'b1) begin
            #1 REGISTER[INADDRESS] = IN;
        end
    end

    //==========REGISTER RESET==========
    // synchronously reset registers at positive edge of clock
    // when the RESET is high
    always @ (posedge CLK)
    begin
        if (RESET == 1'b1) begin
            REGISTER[0] <= #1 8'b000_0000;
            REGISTER[1] <= #1 8'b000_0000;
            REGISTER[2] <= #1 8'b000_0000;
            REGISTER[3] <= #1 8'b000_0000;
            REGISTER[4] <= #1 8'b000_0000;
            REGISTER[5] <= #1 8'b000_0000;
            REGISTER[6] <= #1 8'b000_0000;
            REGISTER[7] <= #1 8'b000_0000;
        end
    end

endmodule