`timescale 1ns / 1ps

module tb_systolic_array;
    reg clk, rst, load;
    reg [31:0] in_a;
    reg [63:0] in_b;
    wire [31:0] out_a;
    wire [63:0] out_b;

    // Fixed integer declarations for the loop
    integer i, j, k, col_idx;
    reg [7:0] A_MAT [0:3][0:3];
    reg [7:0] B_MAT [0:3][0:3];

    systolic_array #(4, 4, 8, 16) uut (
        .clk(clk), .rst(rst), .load(load),
        .in_a(in_a), .in_b(in_b),
        .out_a(out_a), .out_b(out_b)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("systolic.vcd");
        $dumpvars(0, tb_systolic_array);
        
        clk=0; rst=1; load=0; in_a=0; in_b=0;
        
        // Define matrices
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                A_MAT[i][j] = (i==j) ? 8'd1 : 8'd0; // Identity Matrix
                B_MAT[i][j] = 8'd2;
            end
        end

        #20 rst = 0;
        $display("--- Simulation Start ---");
        
        // Load Weights (Row-major)
        load = 1;
        for (i = 3; i >= 0; i = i - 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                in_b[j*16 +: 8] = B_MAT[i][j];
            end
            @(posedge clk);
        end
        load = 0; in_b = 0;

        // Stream Inputs (The Wavefront)
        for (k = 0; k < 12; k = k + 1) begin
            for (i = 0; i < 4; i = i + 1) begin
                col_idx = k - i;
                if (col_idx >= 0 && col_idx < 4) 
                    in_a[i*8 +: 8] = A_MAT[i][col_idx];
                else 
                    in_a[i*8 +: 8] = 0;
            end
            @(posedge clk);
        end

        #100;
        $display("--- Simulation Finished ---");
        $finish;
    end
endmodule