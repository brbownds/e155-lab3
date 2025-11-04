// Broderick Bownds
// brbownds@hmc.edu
// 11/3/2025

// synchronizer_tb

`timescale 1ns/1ps

module synchronizer_tb;

    // DUT inputs
    logic clk;
    logic reset;
    logic [3:0] row;
    logic [3:0] col;

    // DUT outputs
    logic [3:0] row_sync;
    logic [3:0] col_sync;

    // Instantiate DUT
    synchronizer uut (
        .clk(clk),
        .reset(reset),
        .row(row),
        .col(col),
        .row_sync(row_sync),
        .col_sync(col_sync)
    );

    // clock 
    initial clk = 0;
    always #5 clk = ~clk;

  
    initial begin
        // Initialize inputs
        reset = 0;
        row   = 4'b0000;
        col   = 4'b0000;

        // Apply reset
        #20;
        reset = 1;
        $display(" Starting Synchronizer Test ");

        // Wait a few cycles for stable startup
        repeat (3) @(posedge clk);

       
        $display("Testing column synchronization");
        fork
            // Simulate asynchronous column changes
            begin
                #7  col = 4'b0001;   // near clock edge
                #12 col = 4'b0011;   // mid-cycle toggle
                #8  col = 4'b0101;
                #17 col = 4'b1001;
                #9  col = 4'b0000;
            end
        join

        // Allow synchronization pipeline to settle
        repeat (8) @(posedge clk);

        
        $display("Testing row synchronization");
        fork
            begin
                #6  row = 4'b0001;
                #11 row = 4'b0010;
                #14 row = 4'b0110;
                #9  row = 4'b1111;
                #8  row = 4'b0000;
            end
        join

        // Let it settle again
        repeat (8) @(posedge clk);

        $display("Testing simultaneous row/col async activity");
        fork
            begin
                #7  row = 4'b0011;
                #10 col = 4'b1010;
                #6  row = 4'b0100;
                #15 col = 4'b1100;
                #9  row = 4'b1110;
                #5  col = 4'b0001;
            end
        join

        repeat (10) @(posedge clk);

        // end
        $display("\n--- Synchronizer Test Complete ---\n");
        $finish;
    end

   
    initial begin
        $monitor("[%0t ns] clk=%b | row=%b -> row_sync=%b | col=%b -> col_sync=%b",
                 $time, clk, row, row_sync, col, col_sync);
    end

endmodule
