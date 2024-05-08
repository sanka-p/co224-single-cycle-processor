/*
 * dcache.v
 * Desc: Simple data cache module
 * Authors: M. S. Peeris <e19275@eng.pdn.ac.lk>,
 *          A. P. T. T. Perera <e19278@eng.pdn.ac.lk>
 * Group: 41
 * Last Modified: 28/06/2023
 */

`timescale 1ns/100ps
`include "dmem_for_dcache.v"

module m_dcache (
    input clk,
    input reset,
    input read,
    input write,
    input[7:0] address,
    input[7:0] writedata,
    output reg[7:0] readdata,
    output reg busywait
);
    // define data memory and the required signals for it
    output reg mem_read;
    output reg mem_write;
    output reg[5:0] mem_address;
    output reg[31:0] mem_writedata;
    wire[31:0] mem_readdata;
    wire mem_busywait;

    data_memory dmemory(
        clk,
        reset,
        mem_read,
        mem_write,
        mem_address,
        mem_writedata,
        mem_readdata,
        mem_busywait
    );
    
    // define tag, index, offset from current (hence prefix c_) address
    reg[2:0] c_tag, c_index;
    reg[1:0] c_offset;
    always @ (address) begin
        #1; // artificial indexing latency
        c_tag = address[7:5];
        c_index = address[4:2];
        c_offset = address[1:0];
    end

    // halt cpu when a request is signalled
    always @ (read, write) begin
        busywait = ((read || write) && !is_hit)? 1 : 0;
    end
    
    // define data array for storing tags
    reg[2:0] tag[7:0];

    // define data arrays for valid bits
    reg valid[7:0];
    
    // define data arrays for dirty bits
    reg dirty[7:0];

    // define cache array
    reg[31:0] cache[7:0];

    // resolve tag hits and dirty status
    reg is_hit, is_dirty;
    always @ (read, write, c_tag, tag[c_index], valid[c_index], dirty[c_index]) begin
        is_hit <= #0.9 (c_tag == tag[c_index] && valid[c_index]);
        is_dirty <= dirty[c_index];
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, 
              MEM_READ = 3'b001,        // read from data memory
              MEM_WRITE = 3'b010,       // write to data memory
              CACHE_UPDATE = 3'b011;    // write to cache from memory
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE: begin
                // read / write miss - block is not dirty => evict and read required block from memory
                if ((read || write) && !is_dirty && !is_hit) begin  
                    next_state = MEM_READ;
                end
                // read / write miss - block is dirty => write current block to memory and evict
                else if ((read || write) && is_dirty && !is_hit) begin
                    next_state = MEM_WRITE; 
                end          
                else begin
                    next_state = IDLE;
                end
            end

            MEM_WRITE: begin
                if (!mem_busywait) begin
                    // after a memory write, next state should be to always read due to write back policy
                    next_state = MEM_READ;
                end
                else begin
                    // wait until current data memory operation is complete
                    next_state = MEM_WRITE;
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
                0: readdata <= cache[c_index][07:00];
                1: readdata <= cache[c_index][15:08];
                2: readdata <= cache[c_index][23:16];
                3: readdata <= cache[c_index][31:24];
            endcase
        end
    end

    // write data to cache at posedge of clk write hit
    always @ (posedge clk) begin
        if (write && is_hit) begin
            busywait <= 0;
            case (c_offset)
                0: cache[c_index][07:00] <= #1 writedata;
                1: cache[c_index][15:08] <= #1 writedata;
                2: cache[c_index][23:16] <= #1 writedata;
                3: cache[c_index][31:24] <= #1 writedata;
            endcase
            dirty[c_index] <= 1;
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
                    mem_write = 0;
                    mem_address = {c_tag, c_index};
                end
                else if (next_state == MEM_WRITE) begin
                    mem_read = 0;
                    mem_write = 1;
                    mem_address = {tag[c_index], c_index};
                    mem_writedata = cache[c_index];
                end
                else begin
                    mem_read = 0;
                    mem_write = 0;
                    mem_address = 8'dx;
                    mem_writedata = 8'dx;
                end
                if (is_hit || (next_state == IDLE))    
                    busywait = 0;
                else
                    busywait = 1;
            end
         
            MEM_READ: begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {c_tag, c_index};
                mem_writedata = 32'dx;
                busywait = 1;
            end

            MEM_WRITE: begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tag[c_index], c_index};
                mem_writedata = cache[c_index];
                busywait = 1;
            end

            CACHE_UPDATE: begin
                mem_read <= 0;
                mem_write <= 0;
                // mem_address <= 8'dx;
                mem_writedata <= 8'dx;
                cache[c_index] <= mem_readdata;
                dirty[c_index] <= 0;
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
                dirty[i] <= 0;
                cache[i] <= 0;
            end
        end
        else
            state = next_state;
    end

    /* Cache Controller FSM End */

endmodule