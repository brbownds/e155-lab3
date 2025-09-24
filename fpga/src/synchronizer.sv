// Broderick Bownds
// brbownds@hmc.edu
// 9/21/2025

// This module, similar to the sevenseg decoder enables to decoder which number
// is chosen based on the row and/or column being pressed. 

module synchronizer(input logic clk, reset, 
					input logic [3:0] row,
					input  logic [3:0] col,
					output logic [3:0] col_sync,
					output logic [3:0] row_sync);					
    logic [3:0] col1;
	logic [3:0] row1;

   always_ff @(posedge clk) begin
        if (reset==0) begin
            col1     <= 4'b1111;
            col_sync <= 4'b1111;
			row1     <= 4'b1111;
			row_sync <= 4'b1111;
        end else begin
            col1     <= col;
            col_sync <= col1;
			row1     <= row;
			row_sync <= row1;
        end
    end
	
endmodule