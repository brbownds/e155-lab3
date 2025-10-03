//=====================================================
// Testbench for keyscan
// Broderick Bownds
// brbownds@hmc.edu
// 10/3/2025
//=====================================================
`timescale 1ns/1ps

module keyscan_tb;

    // DUT ports
    logic clk;
    logic reset;
    logic [3:0] col;
    logic [3:0] row;
    logic [3:0] led;
    logic [3:0] row_pressed;
    logic debounced;
    logic debounce_en;
    logic drive_en;

    // Delayed row sync (2-cycle delay)
    logic [3:0] row_d1, row_d2;

    // Device under test
    keyscan dut (.*);

    // Clock generation (100 MHz = 10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Row sync delay line (2 cycles behind "row")
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            row1 <= 4'b0000;
			      row_sync <= 4'b0000;
        end else begin
            row1     <= row;
			      row_sync <= row1;
        end
    end

    assign row_pressed = row_sync; // delayed by 2 clocks

    // Stimulus
    initial begin
        // Initialize
        reset = 0;
        col   = 4'b0000;
        debounced = 0;
        #20;
        reset = 1;

        // Wait a few cycles
        repeat(5) @(posedge clk);

        // Simulate pressing a key in row0 / col0
        col = 4'b0001;      // one key pressed
        debounced = 1;      // pretend debounce succeeded
        repeat(4) @(posedge clk);

        // Release key
        col = 4'b0000;
        debounced = 0;
        repeat(6) @(posedge clk);

        // Simulate pressing a key in row2 / col3
        col = 4'b1000; 
        debounced = 1;
        repeat(4) @(posedge clk);

        // Release
        col = 4'b0000;
        debounced = 0;
        repeat(10) @(posedge clk);

        $finish;
    end

    // Monitor
    initial begin
        $display(" time | state | row col led debounce drive");
        $monitor("%4t | %b | %b %b %b %b %b",
                  $time, dut.state, row, col, led, debounce_en, drive_en);
    end

endmodule
