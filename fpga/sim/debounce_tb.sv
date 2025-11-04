// Broderick Bownds
// brbownds@hmc.edu
// 11/3/2025

// debounce_tb

`timescale 1ns/1ps

module debounce_tb;

    // DUT inputs
    logic clk;
    logic reset;
    logic debounce_en;

    // DUT output
    logic debounced;

    // Instantiate DUT
    debounce uut (
        .clk(clk),
        .reset(reset),
        .debounce_en(debounce_en),
        .debounced(debounced)
    );

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    
    initial begin
        // Initialize
        reset = 0;
        debounce_en = 0;
        #20;
        reset = 1;
        $display("\n--- Starting Debounce Test ---\n");

        // test 1
        $display("Testing noisy signal input...");
        // Bouncing pattern: rapid toggling before settling
        debounce_en = 1; #7;
        debounce_en = 0; #6;
        debounce_en = 1; #4;
        debounce_en = 0; #9;
        debounce_en = 1; // finally pressed and held

        // Hold for several cycles
        repeat (10) @(posedge clk);

        // test 2
        $display("Testing release bounce...");
        debounce_en = 0; #5;
        debounce_en = 1; #6;
        debounce_en = 0; #4;
        debounce_en = 1; #8;
        debounce_en = 0; // released

        repeat (10) @(posedge clk);

        // end
        $display("\n--- Debounce Test Complete ---\n");
        $finish;
    end

  
    initial begin
        $monitor("[%0t ns] clk=%b | debounce_en=%b | db_counter=%0d | debounced=%b",
                 $time, clk, debounce_en, uut.db_counter, debounced);
    end

endmodule
