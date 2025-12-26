`timescale 1ns / 1ps

module mini_tpu_top #(
    parameter ROW = 4,
    parameter COL = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire we,                     // Write Enable for loading initial data to RAM
    input  wire [3:0] write_addr,       // Address to write external data
    input  wire [31:0] write_data,      // External data (4 bytes at a time)
    output wire done,
    output wire [(COL*ACC_WIDTH)-1:0] final_out // Result coming out of the bottom
);

    // Internal Signals (The "Nerves" of the TPU)
    wire load_sig;
    wire [3:0] mem_addr;
    wire [31:0] activation_bus;
    wire [63:0] weight_bus; // Using memory output for weights/partial sums

    // 1. Instantiate Control Unit
    control_unit ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .load_signal(load_sig),
        .mem_addr(mem_addr),
        .done(done)
    );

    // 2. Instantiate Unified Buffer (For Activations/Matrix A)
    // We use the mem_addr from the controller during execution
    unified_buffer #(4, 32) activation_mem (
        .clk(clk),
        .we(we),
        .addr(we ? write_addr : mem_addr),
        .din(write_data),
        .dout(activation_bus)
    );

    // 3. Instantiate the Systolic Array
    systolic_array #(ROW, COL, DATA_WIDTH, ACC_WIDTH) array (
        .clk(clk),
        .rst(rst),
        .load(load_sig),
        .in_a(activation_bus),
        .in_b(64'b0), // Initial partial sums are zero
        .out_a(),     // Horizontal output ignored for now
        .out_b(final_out)
    );

endmodule