`timescale 1ns / 1ps

module control_unit (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  load_signal,
    output reg  [3:0] mem_addr,
    output reg  done
);
    // State Definitions
    parameter IDLE = 2'b00, LOAD = 2'b01, EXEC = 2'b10, FINISH = 2'b11;
    reg [1:0] state, next_state;
    reg [3:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    // State Transition & Output Logic
    always @(*) begin
        load_signal = 0;
        done = 0;
        case (state)
            IDLE:   next_state = start ? LOAD : IDLE;
            LOAD:   begin 
                        load_signal = 1; 
                        next_state = (counter == 3) ? EXEC : LOAD; 
                    end
            EXEC:   next_state = (counter == 12) ? FINISH : EXEC;
            FINISH: begin 
                        done = 1; 
                        next_state = IDLE; 
                    end
            default: next_state = IDLE;
        endcase
    end

    // Counter logic for memory addressing
    always @(posedge clk) begin
        if (state == IDLE) counter <= 0;
        else               counter <= counter + 1;
        mem_addr <= counter;
    end
endmodule