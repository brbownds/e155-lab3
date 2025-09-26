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

   always_ff @(posedge clk, negedge reset) begin
        if (reset==0) begin
            col1     <= 4'b0000;
            col_sync <= 4'b0000;  
			row1     <= 4'b0000;
			row_sync <= 4'b0000;
        end else begin
            col1     <= col;
            col_sync <= col1;
			row1     <= row;
			row_sync <= row1;
        end
    end
	
endmodule
