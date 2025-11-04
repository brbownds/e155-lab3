// Broderick Bownds
// brbownds@hmc.edu
// 11/3/2025
// lab3_bb_tb

`timescale 1ns/1ps

module lab3_bb_tb;

    // DUT inputs
    logic reset;
    logic [3:0] col;

    // DUT outputs
    logic [3:0] row;
    logic [6:0] seg;
    logic disp0, disp1;
    logic [3:0] led;

    // Instantiate DUT
    lab3_bb uut (
        .reset(reset),
        .col(col),
        .row(row),
        .seg(seg),
        .disp0(disp0),
        .disp1(disp1),
        .led(led)
    );

        $display("\n--- Starting lab3_bb Simulation ---\n");

        // Initialize
        reset = 0;
        col   = 4'b0000;
        #100;
        reset = 1;

       // test 1
        $display("[Time %0t] Applying simulated keypress sequence...", $time);
        #1000;

        col = 4'b1110; #200000;   // column 0 pressed
        col = 4'b1101; #200000;   // column 1 pressed
        col = 4'b1011; #200000;   // column 2 pressed
        col = 4'b0111; #200000;   // column 3 pressed

       // test 2
        col = 4'b1111;
        #200000;

        //end
        $display("\n--- Simulation Complete ---\n");
        $finish;
    end

   
    initial begin
        $monitor("[%0t ns] reset=%b | col=%b | row=%b | seg=%b | disp0=%b | disp1=%b | led=%b",
                 $time, reset, col, row, seg, disp0, disp1, led);
    end

endmodule
