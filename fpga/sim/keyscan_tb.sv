// Broderick Bownds
// brbownds@hmc.edu
// 9/22/2025

// This module is a testbench for keyscan

module keyscan_tb;
  logic clk, reset;
  logic [3:0] col;
  logic [3:0] row;
  logic [3:0] row_pressed;
  logic       new_num;

  // Instantiate module
  keyscan dut(.*);

  // Clock generation (10ns period)
  always #5 clk = ~clk;

  initial begin
    // Init
    clk = 0;
    reset = 0;
    col = 4'b1111; // no key pressed
    #12 reset = 1;

    // test 1- row0, col0 pressed
    wait(row == 4'b1110);   // dut scanning row0
    col = 4'b1110;          // press col0
    @(posedge clk); #1;
    if (row_pressed !== 4'b0001) $error("Test1 row_pressed mismatch: got %b", row_pressed);
    if (new_num !== 1)      $error("Test1 new_num mismatch: got %b", new_num);
    col = 4'b1111;          // release
    repeat (2) @(posedge clk);

    // test 2- row1, col1 pressed
    wait(row == 4'b1101);   // dut scanning row1
    col = 4'b1101;          // press col1
    @(posedge clk); #1;
    if (row_pressed !== 4'b0010) $error("Test2 row_pressed mismatch: got %b", row_pressed);
    if (new_num !== 1)      $error("Test2 new_num mismatch: got %b", new_num);
    col = 4'b1111;          // release
    repeat (2) @(posedge clk);

    // test 3: row2, col2 pressed 
    wait(row == 4'b1011);   // scanning row2
    col = 4'b1011;          // press col2
    @(posedge clk); #1;
    if (row_pressed !== 4'b0100) $error("Test3 row_pressed mismatch: got %b", row_pressed);
    if (new_num !== 1)      $error("Test3 new_num mismatch: got %b", new_num);
    col = 4'b1111;          // release
    repeat (2) @(posedge clk);

    //  test 4: row3, col3 pressed
    wait(row == 4'b0111);   // scanning row3
    col = 4'b0111;          // press col3
    @(posedge clk); #1;
    if (row_pressed !== 4'b1000) $error("Test4 row_pressed mismatch: got %b", row_pressed);
    if (new_num !== 1)      $error("Test4 new_num mismatch: got %b", new_num);
    col = 4'b1111;          // release
    repeat (2) @(posedge clk);

    $display("All keyscan tests completed.");
    $stop;
  end
endmodule
