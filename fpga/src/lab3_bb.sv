// Broderick Bownds
// brbownds@hmc.edu
// 9/13/2025


// This is our top module with sevenseg module as a submodule which we instantiate contains our HSOSC.
// This is where we divide our clock to generate a slower clock signal so we don't bleed
// or ghost when flickering. 

module lab3_bb( input logic  reset,
				input  logic [3:0] col,
				output  logic [3:0] row,
				output logic [6:0] seg,
				output logic disp0, disp1); 
				
				logic [1:0] select_mux;
				logic int_osc;
				logic [3:0] col_sync;
				//logic [3:0] row_sync; 
				logic [3:0] digit;
				logic [3:0] digit_out;
				logic [3:0] row_pressed;
				logic [24:0] counter = 0; 
				logic new_num; 
				
// Instantiate our HSOSC 
// Internal high-speed oscillator, divides 48MHz into 24MHz because of 2'b01
   HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
  // slow Counter
   always_ff @(posedge int_osc or negedge reset) begin
	   if (~reset) begin
		   counter <= 0; 
		   select_mux <=0; end
     else if(counter == 300000) begin
		 counter <= 0; 
		 select_mux <= ~select_mux;
		 end
     else begin          
		 counter <= counter + 1;
		end
   end
  	 
	// synchronizer syncer(int_osc, reset, row, col, col_sync, row_sync);
	keyscan keyscan(int_osc, reset, col, row, row_pressed, new_num);
	keydecoder keydecoder(row_pressed, col, digit);
    debounce debounce(int_osc, reset, select_mux, digit, digit_out, disp0, disp1);
	sevenseg sevenseg (digit_out, seg);


endmodule