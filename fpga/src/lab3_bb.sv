// Broderick Bownds
// brbownds@hmc.edu
// 9/13/2025


// This is our top module with sevenseg module as a submodule which we instantiate contains our HSOSC.
// This is where we divide our clock to generate a slower clock signal so we don't bleed
// or ghost when flickering. 

module lab3_bb( input logic  notreset,
				input  logic [3:0] col,
				output  logic [3:0] row,
				output logic [6:0] seg,
				output logic disp0, disp1); 
				
				logic select_mux;
				logic reset;
				logic int_osc;
				logic [3:0] col_sync, row_pressed, digit, digit_out;
				logic [24:0] counter;
				logic new_num;
				
	assign row = row_pressed;
// Instantiate our HSOSC 
// Internal high-speed oscillator, divides 48MHz into 24MHz because of 2'b01
   HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

  
  // Counter
   always_ff @(posedge int_osc, negedge reset) begin
	   if (!reset) begin
		   counter <=0; 
		   select_mux <= 1'b0; end
     else if(counter == 1000) begin
		 counter <= 0; 
		 select_mux <= ~select_mux;
		 end
     else begin          
		 counter <= counter + 1;
		end
   end
 
   
	assign reset = ~notreset;
	 
	synchronizer syncer(int_osc, reset, col, col_sync);
		
	keydecoder keydecoder(row_pressed, col_sync, digit);
	
	keyscan keyscan(select_mux, reset, col_sync, row_pressed, new_num);

    debounce debounce(int_osc, reset, new_num, digit, digit_out, disp0, disp1);
	
	sevenseg sevenseg (digit_out, seg);

endmodule	