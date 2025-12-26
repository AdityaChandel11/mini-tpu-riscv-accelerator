`timescale 1ns / 1ps

module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire load,
    input  wire [DATA_WIDTH-1:0] in_a,
    input  wire [ACC_WIDTH-1:0]  in_b,
    output reg  [DATA_WIDTH-1:0] out_a,
    output reg  [ACC_WIDTH-1:0]  out_b
);
    // Internal register to store the weight
    reg [DATA_WIDTH-1:0] weight;

    always @(posedge clk) begin
        if (rst) begin
            out_a  <= 0;
            out_b  <= 0;
            weight <= 0;
        end else if (load) begin
            // When loading, B input carries the weight
            weight <= in_b[DATA_WIDTH-1:0];
        end else begin
            // Systolic move: Pass A to the right, and MAC result to the bottom
            out_a <= in_a;
            out_b <= in_b + (in_a * weight);
        end
    end
endmodule