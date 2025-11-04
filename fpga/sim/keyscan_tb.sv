
// Broderick Bownds
// brbownds@hmc.edu
// 10/16/2025

//keyscan_tb

`timescale 1ns/1ps

module keyscan_tb;

    // Inputs
    logic clk;
    logic reset;
    logic [3:0] col;
    logic [3:0] row_pressed;
    logic debounced;

    // Outputs
    logic [3:0] row;
    logic [3:0] led;
    logic debounce_en;
    logic drive_en;

    // Instantiate DUT (Device Under Test)
    keyscan uut (
        .clk(clk),
        .reset(reset),
        .col(col),
        .row(row),
        .led(led),
        .row_pressed(row_pressed),
        .debounced(debounced),
        .debounce_en(debounce_en),
        .drive_en(drive_en)
    );

	// generate clock
    initial clk = 0;
    always #5 clk = ~clk;

    
    initial begin
        // Initialize all signals
        reset        = 0;
        col          = 4'b0000;
        row_pressed  = 4'b0000;
        debounced    = 0;

        // Hold reset low briefly
        #20;
        reset = 1;
        $display(" Starting keyscan FSM Test ");

        // Let the FSM stabilize in R0_IDLE
        #40;

        // row 0 active
        $display("Testing Row 0");
        row_pressed = 4'b0001;   // Indicate row 0 is active
        col         = 4'b0001;   // One button pressed
        debounced   = 1;         // Debounced signal asserted
        #40;
        debounced   = 0;
        col         = 4'b0000;
        #40;

        // row 1 active
        $display("Testing Row 1");
        row_pressed = 4'b0010;   // Row 1 pressed
        col         = 4'b0010;
        debounced   = 1;
        #40;
        debounced   = 0;
        col         = 4'b0000;
        #40;

        // row 2 active
        $display("Testing Row 2");
        row_pressed = 4'b0100;
        col         = 4'b0100;
        debounced   = 1;
        #40;
        debounced   = 0;
        col         = 4'b0000;
        #40;

        // row 3 active
        $display("Testing Row 3");
        row_pressed = 4'b1000;
        col         = 4'b1000;
        debounced   = 1;
        #40;
        debounced   = 0;
        col         = 4'b0000;
        #40;

        // drive enable test
        $display("Testing drive_en and debounce_en control signals");
        row_pressed = 4'b0001;
        col         = 4'b0001;
        debounced   = 1;
        #20;
        $display("drive_en=%b, debounce_en=%b (expected both 1)", drive_en, debounce_en);
        debounced   = 0;
        #20;

        $display("\n--- Simulation Complete ---\n");
        $finish;
    end

  
    initial begin
        $monitor("[%0t ns] state: row=%b  col=%b  row_pressed=%b  debounced=%b  drive_en=%b  debounce_en=%b",
                 $time, row, col, row_pressed, debounced, drive_en, debounce_en);
    end

endmodule
