// Broderick Bownds
// brbownds@hmc.edu
// 9/22/2025

//   Scans a matrix keypad by driving rows and sampling columns.
//   The module cycles through each row, grounding one at a time,
//   and checking which column lines are active to detect pressed keys.


module keyscan (
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] col,    // keypad columns (inputs)
	output logic [3:0] row, led, // row drive (active high)
	input  logic [3:0] row_pressed, //(row_sync)
	input logic       debounced,
	output logic      debounce_en,
	output logic      drive_en
);

    // 1) FSM states
typedef enum logic [3:0] {
    R0_IDLE, R0_WAIT, R0_HOLD,
    R1_IDLE, R1_WAIT, R1_HOLD,
    R2_IDLE, R2_WAIT, R2_HOLD,
    R3_IDLE, R3_WAIT, R3_HOLD,
    CHECK, DRIVE
} statetype;

statetype state, nextstate;

    logic  button_pressed;
    logic  exact1_button;              // strobe
	logic  if_0, if_1, if_2, if_3;

	always_ff @(posedge clk, negedge reset) begin
		if (reset == 0) begin
			state         <= R0_IDLE;
			button_pressed <= 1'b0;
			exact1_button  <= 1'b0;
		end else begin
			state         <= nextstate;
			button_pressed <= ($countones(col)>0);
			exact1_button  <= ($countones(col)==1);
    end
end

	
	assign if_0 = row_pressed[0]; // TODO
	assign if_1 = row_pressed[1];
	assign if_2 = row_pressed[2];
	assign if_3 = row_pressed[3];
	
	/*assign led[0] = (state == R0_WAIT);
	assign led[1] = (state == R1_WAIT);
	assign led[2] = (state == R2_WAIT);
	assign led[3] = (state == R3_WAIT);
	*/
	assign led[0] = row_pressed[0];
	assign led[1] = row_pressed[1];
	assign led[2] = row_pressed[2];
	assign led[3] = exact1_button;



  always_comb begin 
	  		nextstate = R0_IDLE;
			case (state)
        R0_IDLE: nextstate = exact1_button ? R0_WAIT : R1_IDLE;
        R0_WAIT: nextstate = debounced      ? CHECK   : R0_WAIT;
        R0_HOLD: nextstate = button_pressed ? R0_HOLD : R1_IDLE;

        R1_IDLE: nextstate = exact1_button ? R1_WAIT : R2_IDLE;
        R1_WAIT: nextstate = debounced      ? CHECK   : R1_WAIT;
        R1_HOLD: nextstate = button_pressed ? R1_HOLD : R2_IDLE;

        R2_IDLE: nextstate = exact1_button ? R2_WAIT : R3_IDLE;
        R2_WAIT: nextstate = debounced      ? CHECK   : R2_WAIT;
        R2_HOLD: nextstate = button_pressed ? R2_HOLD : R3_IDLE;

        R3_IDLE: nextstate = exact1_button ? R3_WAIT : R0_IDLE;
        R3_WAIT: nextstate = debounced      ? CHECK   : R3_WAIT;
        R3_HOLD: nextstate = button_pressed ? R3_HOLD : R0_IDLE;

        CHECK:   nextstate = exact1_button ? DRIVE : R0_IDLE;

        DRIVE: begin
            if (button_pressed) begin
                if      (if_0) nextstate = R0_HOLD;
                else if (if_1) nextstate = R1_HOLD;
                else if (if_2) nextstate = R2_HOLD;
                else if (if_3) nextstate = R3_HOLD;
                else           nextstate = R0_IDLE; // safety
            end 
            else begin
                // if no button pressed, cycle back to R0 idle (or wherever you want)
                nextstate = R0_IDLE;
            end
		end

    endcase
end

	
    always_comb begin
        case (state)
            R0_IDLE, R0_WAIT, R0_HOLD: row = 4'b0001;
            R1_IDLE, R1_WAIT, R1_HOLD: row = 4'b0010;
            R2_IDLE, R2_WAIT, R2_HOLD: row = 4'b0100;
            R3_IDLE, R3_WAIT, R3_HOLD: row = 4'b1000;
			default:          row = 4'b0001;
        endcase
    end
	

	assign debounce_en =( (state == R0_WAIT) || (state == R1_WAIT) || (state == R2_WAIT) || (state == R3_WAIT));
	assign drive_en = (state == DRIVE);

endmodule
