`timescale 1ns / 1ps

module tb_mini_tpu_top;
    reg clk, rst, start, we;
    reg [3:0] write_addr;
    reg [31:0] write_data;
    wire done;
    wire [63:0] final_out;

    // Instantiate Top Module
    mini_tpu_top uut (
        .clk(clk), .rst(rst), .start(start), .we(we),
        .write_addr(write_addr), .write_data(write_data),
        .done(done), .final_out(final_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tpu_system.vcd");
        $dumpvars(0, tb_mini_tpu_top);
        
        // Initialize
        clk=0; rst=1; start=0; we=0; write_addr=0; write_data=0;
        #20 rst = 0;

        // --- STEP 1: HOST LOADS DATA INTO TPU RAM ---
        $display("Host: Loading Activation Matrix into Unified Buffer...");
        we = 1;
        // Loading an Identity Matrix (4 rows of 32-bit data)
        write_addr = 0; write_data = 32'h00000001; #10;
        write_addr = 1; write_data = 32'h00000100; #10;
        write_addr = 2; write_data = 32'h00010000; #10;
        write_addr = 3; write_data = 32'h01000000; #10;
        we = 0;

        // --- STEP 2: TRIGGER TPU EXECUTION ---
        #20 start = 1;
        #10 start = 0; // Pulse start
        $display("TPU: Execution Started...");

        // Wait for Done signal
        wait(done);
        $display("TPU: Execution Complete!");
        
        #100;
        $finish;
    end
endmodule