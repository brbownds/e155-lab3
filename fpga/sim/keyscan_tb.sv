
`timescale 1ns/1ps

module keyscan_tb;

  // Testbench signals
  logic clk;
  logic reset;
  logic [3:0] col;
  logic [3:0] row;
  logic [3:0] led;
  logic [3:0] row_pressed;
  logic debounced;
  logic debounce_en;
  logic drive_en;

  // Instantiate DUT
  keyscan dut (.*);

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz clock

  // Stimulus
  initial begin
    // Initialize
    reset = 0;
    col = 4'b0000;
    row_pressed = 4'b0000;
    debounced = 0;
	
    // Apply reset
    #20 reset = 1;

    // Keep debounced high for testing
    #10 debounced = 1;

    // --- Test Row 0 ---
    $display("Testing Row 0...");
    col = 4'b0001; row_pressed = 4'b0001;
    #50;
    col = 4'b0000; row_pressed = 4'b0000;
    #20;

    // --- Test Row 1 ---
    $display("Testing Row 1...");
    col = 4'b0010; row_pressed = 4'b0010;
    #50;
    col = 4'b0000; row_pressed = 4'b0000;
    #20;

    // --- Test Row 2 ---
    $display("Testing Row 2...");
    col = 4'b0100; row_pressed = 4'b0100;
    #50;
    col = 4'b0000; row_pressed = 4'b0000;
    #20;

    // --- Test Row 3 ---
    $display("Testing Row 3...");
    col = 4'b1000; row_pressed = 4'b1000;
    #50;
    col = 4'b0000; row_pressed = 4'b0000;
    #20;

    // End simulation
    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor("t=%0t | row=%b col=%b row_pressed=%b led=%b debounced=%b debounce_en=%b drive_en=%b",
              $time, row, col, row_pressed, led, debounced, debounce_en, drive_en);
  end

endmodule

