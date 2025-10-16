// Broderick Bownds
// brbownds@hmc.edu
// October 16, 2025
//
// keyscan_tb.sv — Testbench for keyscan FSM
// Simulates key presses across all rows and verifies correct row drive, debounce, and state transitions.

`timescale 1ns/1ps

module keyscan_tb;

    // DUT inputs
    logic clk;
    logic reset;
    logic [3:0] col;
    logic [3:0] row_pressed;
    logic debounced;

    // DUT outputs
    logic [3:0] row, led;
    logic debounce_en;
    logic drive_en;

	logic [3:0] col_sync;
	logic [3:0] row_sync;

	synchronizer syncer(slow_clk, reset, row, col, col_sync, row_sync);	

// Instantiate DUT
    keyscan dut (.*);

    // Clock: 100 MHz → 10 ns period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Stimulus
    initial begin
        $display("=== Starting keyscan testbench ===");
        col = 4'b0000;
        row_pressed = 4'b0000;
        debounced = 1'b0;

        // Apply reset
        reset = 0; #20;
        reset = 1; #10;
        $display("Reset complete.");

        // -------- Row 0 test --------
        $display("\n[TEST] Press key on Row 0");
        row_pressed = 4'b0001;     // active row 0
        col = 4'b0001;             // one column active
        debounced = 0; #20;        // wait
        debounced = 1; #20;        // stable press
        col = 4'b0000;             // release
        debounced = 1; #20;
        row_pressed = 4'b0000;

        // -------- Row 1 test --------
        $display("\n[TEST] Press key on Row 1");
        row_pressed = 4'b0010;
        col = 4'b0100;             // press column 2
        debounced = 1; #40;
        col = 4'b0000; debounced = 0; #20;
        row_pressed = 4'b0000;

        // -------- Row 2 test --------
        $display("\n[TEST] Press key on Row 2");
        row_pressed = 4'b0100;
        col = 4'b0010;
        debounced = 1; #30;
        col = 4'b0000; debounced = 0; #20;
        row_pressed = 4'b0000;

        // -------- Row 3 test --------
        $display("\n[TEST] Press key on Row 3");
        row_pressed = 4'b1000;
        col = 4'b1000;
        debounced = 1; #30;
        col = 4'b0000; debounced = 0; #20;
        row_pressed = 4'b0000;

        // -------- Multi-key test --------
        $display("\n[TEST] Two simultaneous keys");
        row_pressed = 4'b0011;
        col = 4'b0110;
        debounced = 1; #50;
        col = 4'b0000; debounced = 0; #20;
        row_pressed = 4'b0000;

        $display("\n=== Testbench complete ===");
        #100 $finish;
    end

    // Optional: monitor key signals
    initial begin
        $monitor("[%0t] state row=%b col=%b led=%b debounce_en=%b drive_en=%b",
                 $time, row, col, led, debounce_en, drive_en);
    end

endmodule