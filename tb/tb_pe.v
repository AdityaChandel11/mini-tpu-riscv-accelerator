`timescale 1ns / 1ps

module tb_pe;

    // Inputs to DUT (Device Under Test)
    reg clk;
    reg rst;
    reg load;
    reg [7:0] in_a;
    reg [15:0] in_b;

    // Outputs from DUT
    wire [7:0] out_a;
    wire [15:0] out_b;

    // Instantiate the PE
    pe uut (
       .clk(clk), 
       .rst(rst), 
       .load(load), 
       .in_a(in_a), 
       .in_b(in_b), 
       .out_a(out_a), 
       .out_b(out_b)
    );

    // Generate Clock (10ns period = 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Setup for Waveform Viewer (GTKWave)
        $dumpfile("pe_wave.vcd");
        $dumpvars(0, tb_pe);

        // Initialize
        clk = 0; rst = 1; load = 0; in_a = 0; in_b = 0;
        
        // Reset the system
        #20 rst = 0;
        $display("Status: Reset Complete.");

        // TEST 1: Load Weight
        // We want to load the value '5' into the PE
        #10 load = 1; in_b = 16'd5;
        #10 load = 0; in_b = 0; // Turn off load mode
        $display("Status: Loaded Weight = 5.");

        // TEST 2: Perform Computation
        // Calculate: 10 * 5 + 20 (Input * Weight + Partial_Sum)
        #10 in_a = 8'd10; in_b = 16'd20;
        
        // Wait for clock edge to process
        #10;
        
        // Check Result
        $display("Inputs: A=10, B=20, Weight=5");
        $display("Output B (Result): %d (Expected: 70)", out_b);
        $display("Output A (Passed): %d (Expected: 10)", out_a);

        if (out_b == 70) $display(">> SUCCESS: MAC Operation Verified!");
        else $display(">> FAILURE: MAC Operation Wrong!");

        #20 $finish;
    end

endmodule 