`timescale 1ns / 1ps

module systolic_array #(
    parameter ROW = 4,
    parameter COL = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire load,
    // Inputs are now multi-bit buses
    input  wire [(ROW*DATA_WIDTH)-1:0] in_a, 
    input  wire [(COL*ACC_WIDTH)-1:0]  in_b,
    output wire [(ROW*DATA_WIDTH)-1:0] out_a,
    output wire [(COL*ACC_WIDTH)-1:0]  out_b
);

    // Internal "wire mesh" to connect PEs
    wire [DATA_WIDTH-1:0] h_wire [0:ROW-1][0:COL];
    wire [ACC_WIDTH-1:0]  v_wire [0:ROW][0:COL-1];

    genvar i, j;
    generate
        // Connect external inputs to the boundary wires
        for (i = 0; i < ROW; i = i + 1) begin : drive_west
            assign h_wire[i][0] = in_a[DATA_WIDTH*(i+1)-1 : DATA_WIDTH*i];
            assign out_a[DATA_WIDTH*(i+1)-1 : DATA_WIDTH*i] = h_wire[i][COL];
        end

        for (j = 0; j < COL; j = j + 1) begin : drive_north
            assign v_wire[0][j] = in_b[ACC_WIDTH*(j+1)-1 : ACC_WIDTH*j];
            assign out_b[ACC_WIDTH*(j+1)-1 : ACC_WIDTH*j] = v_wire[ROW][j];
        end

        // Instantiate the grid
        for (i = 0; i < ROW; i = i + 1) begin : row_loop
            for (j = 0; j < COL; j = j + 1) begin : col_loop
                pe #(DATA_WIDTH, ACC_WIDTH) pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .load(load),
                    .in_a(h_wire[i][j]),
                    .in_b(v_wire[i][j]),
                    .out_a(h_wire[i][j+1]),
                    .out_b(v_wire[i+1][j])
                );
            end
        end
    endgenerate
endmodule