`timescale 1ns / 1ps

module unified_buffer #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32 // 4 rows * 8 bits
)(
    input  wire clk,
    input  wire we,                // Write Enable
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout
);
    reg [DATA_WIDTH-1:0] ram [0:(2**ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we) ram[addr] <= din;
        dout <= ram[addr];
    end
endmodule