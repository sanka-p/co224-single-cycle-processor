// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne

`include "cpu.v"

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    reg[31:0] INSTRUCTION_REG;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg[7:0] instr_mem[1023:0];
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)   
    always @ (PC)
        #2 INSTRUCTION_REG = {instr_mem[PC + 3], instr_mem[PC + 2], instr_mem[PC + 1], instr_mem[PC]} ;
    assign INSTRUCTION = INSTRUCTION_REG;
 
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem

        // Test 1 - BNE and MULT
        // Machine program to implement following loop in c
            // int i = 2
            // do {
            //    i *= 2;
            // } 
            // while (i != 64);
        // {instr_mem[10'd0], instr_mem[10'd1], instr_mem[10'd2], instr_mem[10'd3]} = 32'b00000010_00000000_00000000_00000000; // load r0 2
        // {instr_mem[10'd4], instr_mem[10'd5], instr_mem[10'd6], instr_mem[10'd7]} = 32'b01000000_00000000_00000001_00000000; // load r1 64
        // {instr_mem[10'd8], instr_mem[10'd9], instr_mem[10'd10], instr_mem[10'd11]} = 32'b00000010_00000000_00000010_00000000; // load r2 2
        // {instr_mem[10'd12], instr_mem[10'd13], instr_mem[10'd14], instr_mem[10'd15]} = 32'b00000010_00000000_00000000_00001100; // mult r0 with r2 and store r0
        // {instr_mem[10'd16], instr_mem[10'd17], instr_mem[10'd18], instr_mem[10'd19]} = 32'b00000001_00000000_11111110_00001101; // if r0 != r1 jump 2 instructions back

        // Test 2 - BNE and LOGICAL SHIFT LEFT
        // Machine program to implement following loop in c
            // int i = 2
            // do {
            //    i << 1;
            // } 
            // while (i != 64);
        // {instr_mem[10'd0], instr_mem[10'd1], instr_mem[10'd2], instr_mem[10'd3]} = 32'b00000010_00000000_00000000_00000000; // load r0 2
        // {instr_mem[10'd4], instr_mem[10'd5], instr_mem[10'd6], instr_mem[10'd7]} = 32'b01000000_00000000_00000001_00000000; // load r1 64
        // {instr_mem[10'd8], instr_mem[10'd9], instr_mem[10'd10], instr_mem[10'd11]} = 32'b00000001_00000000_00000000_00001110; // sll r0 << 1 and store r0
        // {instr_mem[10'd12], instr_mem[10'd13], instr_mem[10'd14], instr_mem[10'd15]} = 32'b00000001_00000000_11111110_00001101; // if r0 != r1 jump 2 instructions back

        // Test 3 - BNE and LOGICAL SHIFT RIGHT
        // Machine program to implement following loop in c
            // int i = 64
            // do {
            //    i >> 1;
            // } 
        //     // while (i != 2);
        // {instr_mem[10'd0], instr_mem[10'd1], instr_mem[10'd2], instr_mem[10'd3]} = 32'b00000010_00000000_00000000_00000000; // load r0 2
        // {instr_mem[10'd4], instr_mem[10'd5], instr_mem[10'd6], instr_mem[10'd7]} = 32'b01000000_00000000_00000001_00000000; // load r1 64
        // {instr_mem[10'd8], instr_mem[10'd9], instr_mem[10'd10], instr_mem[10'd11]} = 32'b00000001_00000001_00000001_00001111; // slr r1 >> 1 and store r1
        // {instr_mem[10'd12], instr_mem[10'd13], instr_mem[10'd14], instr_mem[10'd15]} = 32'b00000001_00000000_11111110_00001101; // if r0 != r1 jump 2 instructions back

        // TEST 4 - RIGHT ROTATER
        {instr_mem[10'd0], instr_mem[10'd1], instr_mem[10'd2], instr_mem[10'd3]} = 32'b00000010_00000000_00000000_00000000; // load r0 2
        {instr_mem[10'd4], instr_mem[10'd5], instr_mem[10'd6], instr_mem[10'd7]} = 32'b00001000_00000000_00000001_00000000; // load r1 64
        {instr_mem[10'd8], instr_mem[10'd9], instr_mem[10'd10], instr_mem[10'd11]} = 32'b00000001_00000001_00000001_00010000; // ror r1 by 1 and store r1
        {instr_mem[10'd12], instr_mem[10'd13], instr_mem[10'd14], instr_mem[10'd15]} = 32'b00000001_00000000_11111110_00001101; // if r0 != r1 jump 2 instructions back

        // // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("programmer/instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    // counter to iterate through and adress registers in reg_file
    integer i;

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);

        for(i = 0; i < 8; i = i +1)
        begin
            $dumpvars(1, cpu_tb.mycpu.cpu_reg_file.REGISTER[i]);
        end
        
        CLK = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        RESET = 1'b0;
        #4
        RESET = 1'b1;
        #1
        RESET = 1'b0;

        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule