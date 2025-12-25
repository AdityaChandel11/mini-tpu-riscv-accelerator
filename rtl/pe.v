`timescale 1ns / 1ps

module pe (
    input  wire        clk,      // System Clock (Heartbeat)
    input  wire        rst,      // Reset
    input  wire        load,     // Active High: Load Weight mode
    input  wire [7:0]  in_a,     // Input Activation (from West)
    input  wire [15:0] in_b,     // Input Partial Sum OR Weight (from North)
    
    output reg  [7:0]  out_a,    // Output Activation (to East)
    output reg  [15:0] out_b     // Output Partial Sum (to South)
);

    // Internal register to hold the stationary weight
    reg [7:0] weight_reg;

    always @(posedge clk) begin
        if (rst) begin
            out_a      <= 8'd0;
            out_b      <= 16'd0;
            weight_reg <= 8'd0;
        end else if (load) begin
            // WEIGHT LOADING PHASE
            // Pass the weight down to the neighbor below (so they can load too)
            out_b      <= in_b;
            // Store the weight locally (take bottom 8 bits)
            weight_reg <= in_b[7:0];
            // Block activation flow during load
            out_a      <= 8'd0; 
        end else begin
            // COMPUTE PHASE
            // 1. Pass input A to the neighbor on the right
            out_a <= in_a;
            
            // 2. Multiply and Accumulate (MAC)
            // out_b = partial_sum_from_above + (input * weight)
            out_b <= in_b + (in_a * weight_reg);
        end
    end

endmodule