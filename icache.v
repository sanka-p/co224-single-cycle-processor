/*
 * icache.v
 * Desc: Simple instruction cache module
 * Authors: M. S. Peeris <e19275@eng.pdn.ac.lk>,
 *          A. P. T. T. Perera <e19278@eng.pdn.ac.lk>
 * Group: 41
 * Last Modified: 28/06/2023
 */

`timescale 1ns/100ps
`include "imem_for_icache.v"

module m_icache (
    input clk,
    input reset,
    input read,
    input[31:0] address,
    output reg[31:0] readdata,
    output reg busywait
);
    // define data memory and the required signals for it
    output reg mem_read;
    output reg[5:0] mem_address;
    wire[127:0] mem_readdata;
    wire mem_busywait;

    instruction_memory imemory(
        clk,
        mem_read,
        mem_address,
        mem_readdata,
        mem_busywait
    );
    
    // define tag, index, offset from current (hence prefix c_) address
    reg[2:0] c_tag, c_index;
    reg[1:0] c_offset;
    always @ (address) begin
        #1; // artificial indexing latency
        c_tag = address[31:7];
        c_index = address[6:4];
        c_offset = address[3:2];
    end

    // halt cpu when a request is signalled and miss is identified
    always @ (read) begin
        busywait = (read && !is_hit)? 1 : 0;
    end
    
    // define data array for storing tags
    reg[24:0] tag[7:0];

    // define data arrays for valid bits
    reg valid[7:0];

    // define cache array
    reg[127:0] cache[7:0];

    // resolve tag hits and dirty status
    reg is_hit;
    always @ (read, c_tag, tag[c_index], valid[c_index]) begin
        is_hit <= #0.9 (c_tag == tag[c_index] && valid[c_index]);
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, 
              MEM_READ = 3'b001,        // read from data memory
              CACHE_UPDATE = 3'b011;    // write to cache from memory
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE: begin
                // read miss - block is not dirty => evict and read required block from memory
                if (read && !is_hit) begin  
                    next_state = MEM_READ;
                end        
                else begin
                    next_state = IDLE;
                end
            end
            
            MEM_READ: begin
                if (!mem_busywait)
                    // write new block to cache from memory
                    next_state = CACHE_UPDATE;
                else
                    // wait until current data memory operation is complete    
                    next_state = MEM_READ;
            end

            CACHE_UPDATE: begin
                next_state = IDLE;
            end
        endcase
    end

    // serve data asynchronously if read is enabled and data is available
    always @ (read, is_hit) begin
        if (read && is_hit) begin
            case (c_offset)
                0: readdata <= cache[c_index][031:000];
                1: readdata <= cache[c_index][063:032];
                2: readdata <= cache[c_index][095:064];
                3: readdata <= cache[c_index][127:096];
            endcase
        end
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE: begin
                if (next_state == MEM_READ)begin
                    // set mem_read signal as soon as the miss is detected
                    mem_read = 1;
                    mem_address = {c_tag, c_index};
                end
                else begin
                    mem_read = 0;
                    mem_address = 8'dx;
                end
                if (is_hit || (next_state == IDLE))    
                    busywait = 0;
                else
                    busywait = 1;
            end
         
            MEM_READ: begin
                mem_read = 1;
                mem_address = {c_tag, c_index};
                busywait = 1;
            end

            CACHE_UPDATE: begin
                mem_read <= 0;
                cache[c_index] <= mem_readdata;
                valid[c_index] <= 1;
                tag[c_index] <= c_tag;
                busywait <= 0;
            end    
        endcase
    end

    integer i;
    // sequential logic for state transitioning 
    always @(posedge clk, reset)
    begin
        if(reset) begin
            state = IDLE;
            // reset data arrays
            for (i = 0; i < 8; i++) begin
                tag[i] <= 0;
                valid[i] <= 0;
                cache[i] <= 0;
            end
        end
        else
            state = next_state;
    end

    /* Cache Controller FSM End */

endmodule