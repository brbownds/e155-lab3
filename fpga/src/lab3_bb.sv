// Broderick Bownds
// brbownds@hmc.edu
// 9/13/2025


// This is our top module with sevenseg module as a submodule which we instantiate contains our HSOSC.
// This is where we divide our clock to generate a slower clock signal so we don't bleed
// or ghost when flickering. 

module lab3_bb( input logic  reset,
				input  logic [3:0] col,
				output  logic [3:0] row,
				output logic [6:0]  seg,
				output logic disp0, disp1,
				output logic [3:0] led); 
				
				logic slow_clk;
				logic int_osc;
				logic [3:0] col_sync;
				logic [3:0] row_sync;
				logic [3:0] digit, digit_out, s1, s0;
				logic [24:0] counter; 
				logic debounce_en, select, debounced;
				logic drive_en; 
				
// Instantiate our HSOSC 
// Internal high-speed oscillator, divides 48MHz into 24MHz because of 2'b01
   HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc)); 
	
  // slow Counter
	always_ff @(posedge int_osc, negedge reset) begin
	   if (reset==0) begin
		   counter <= 0; 
		   slow_clk <=0;
		   select <= 1'b0;
		end
     else if(counter == 50000) begin
		 counter <= 0; 
		 slow_clk <= ~slow_clk;
		 select <= ~select;
      end
     else begin          
		 counter <= counter + 1;
		end
   end
   
   
   // shift bit register
   always_ff @(posedge slow_clk, negedge reset) begin
    if (reset==0) begin
        s0 <= 1'b0;
        s1 <= 1'b0;
    end else if (drive_en) begin
        s0 <= digit;   // load new value
        s1 <= s0;  // shift old value down
    end
end

    assign digit_out = select ? s1 : s0;

	assign disp0 = select;
	assign disp1 = ~select;

  	 
	synchronizer syncer(slow_clk, reset, row, col, col_sync, row_sync);	
	
	keyscan keyscan(slow_clk, reset, col, row, led, row_sync, debounced, debounce_en, drive_en);

	keydecoder keydecoder(row_sync, col_sync, digit);
    
	debouncer debouncer(slow_clk, reset, debounce_en, debounced);  
	
	sevenseg sevenseg (digit_out, seg);


endmodule


