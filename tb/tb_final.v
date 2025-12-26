// --- This replaces the manual 'for (i=0; i<30; i=i+1)' loop from Phase 4 ---

`timescale 1ns / 1ps

module tb_final; // Renamed for clarity: tb_final

    // ... (Signals and UUT instantiation remain the same as tb_mini_tpu_top.v) ...
    // ... (Clock generation remains the same) ...

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 6; // 64 locations deep
    parameter MEMORY_FILE = "memory_init.hex";
    
    // Signals
    reg clk, rst, start;
    wire done;
    
    // CPU Interface
    reg [ADDR_WIDTH-1:0] cpu_addr;
    reg [DATA_WIDTH-1:0] cpu_data;
    reg cpu_we;
    
    // Output Monitoring
    wire [31:0] result_out; 

    // Instantiate the Top Level Chip (Assuming mini_tpu_top.v is compiled with this)
    mini_tpu_top uut (
        .clk(clk), .rst(rst), .start(start), .done(done),
        .cpu_write_addr(cpu_addr), .cpu_write_data(cpu_data), .cpu_write_en(cpu_we),
        .result_out(result_out)
    );
    
    // Clock
    always #5 clk = ~clk;

    // Memory array for loading data from file
    reg [DATA_WIDTH-1:0] initial_memory [0:31]; 
    integer i;

    initial begin
        $dumpfile("final_tpu.vcd");
        $dumpvars(0, tb_final);
        
        clk = 0; rst = 1; start = 0; cpu_we = 0;

        // --- PHASE 1: LOAD HOST MEMORY FROM FILE ---
        $display("[Host CPU] Reading Memory File: %s", MEMORY_FILE);
        // $readmemh reads the hex file into the 'initial_memory' array
        $readmemh(MEMORY_FILE, initial_memory); 

        // --- PHASE 2: HOST LOADS TPU MEMORY ---
        #20 rst = 0;
        $display("[Host CPU] Transferring data to TPU RAM...");
        
        // Loop through the loaded array and write word by word to the TPU RAM
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk);
            cpu_we = 1;
            cpu_addr = i;
            cpu_data = initial_memory[i];
            $display("Time: %0t | Writing %h to Addr %d", $time, initial_memory[i], i);
        end
        @(posedge clk);
        cpu_we = 0; // Stop writing

        // --- PHASE 3: HOST TRIGGERS TPU ---
        $display("[Host CPU] Memory Loaded. Starting TPU...");
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // --- PHASE 4: WAIT FOR COMPLETION & VERIFY ---
        wait(done);
        $display("[Host CPU] Interrupt Received: TPU Done at time %0t.", $time);
        
        #10;
        // Expected result for A*B: 4 columns of the number 3 (03)
        // 03030303 (hex)
        $display("Final Result Output (Hex): %h", result_out); 
        
        // You should compare 'result_out' against the Golden Model C_golden here 
        // to finalize the verification.
        
        $finish;
    end

endmodule