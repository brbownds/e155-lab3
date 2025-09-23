//Broderick Bownds
// brbownds@hmc.edu
// 9/22/2025

// Testbench module for keydecoder
module keydecoder_tb;
  logic [3:0] row, col;
  logic [3:0] digit;
  logic [3:0] expected;
  int errors = 0;

  // Instantiate DUT
  keydecoder dut (.row(row), .col(col), .digit(digit));

  // Task to apply stimulus and check result
  task check(input logic [3:0] t_row, t_col, input logic [3:0] exp);
    begin
      row = t_row;
      col = t_col;
      expected = exp;
      #1; // allow time for combinational logic to evaluate
      if (digit !== expected) begin
        $display("ERROR: row=%b col=%b -> digit=%b (expected %b)",
                 row, col, digit, expected);
        errors++;
      end
    end
  endtask

  initial begin
    // Apply test vectors (from the case table)
    check(4'b0001, 4'b0001, 4'b0001); // 1
    check(4'b0001, 4'b0010, 4'b0010); // 2
    check(4'b0001, 4'b0100, 4'b0011); // 3
    check(4'b0001, 4'b1000, 4'b1010); // A
    check(4'b0010, 4'b0001, 4'b0100); // 4
    check(4'b0010, 4'b0010, 4'b0101); // 5
    check(4'b0010, 4'b0100, 4'b0110); // 6
    check(4'b0010, 4'b1000, 4'b1011); // B
    check(4'b0100, 4'b0001, 4'b0111); // 7
    check(4'b0100, 4'b0010, 4'b1000); // 8
    check(4'b0100, 4'b0100, 4'b1001); // 9
    check(4'b0100, 4'b1000, 4'b1100); // C
    check(4'b1000, 4'b0001, 4'b1110); // E
    check(4'b1000, 4'b0010, 4'b0000); // 0
    check(4'b1000, 4'b0100, 4'b1111); // F
    check(4'b1000, 4'b1000, 4'b1101); // D

    // Try an invalid input (should go to default = 0000)
    check(4'b0011, 4'b0011, 4'b0000);

    // Report results
    if (errors == 0)
      $display("All tests PASSED!");
    else
      $display("%0d tests FAILED", errors);

    $stop;
  end
endmodule
