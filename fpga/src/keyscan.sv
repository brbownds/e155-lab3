// Broderick Bownds
// brbownds@hmc.edu
// 9/20/25

// This module contains the main fsm for the rows as it is scanning to 
// make sure it is hitting the right row. The states are IDLE, BUTTON_PRESSED, and HOLD


module keyscan (
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] col,    // keypad columns (inputs)
	output logic [3:0] row, // row drive (active low)
	output logic [3:0] row_pressed,
	output logic        new_num
);

    // 1) FSM states
    typedef enum logic [3:0] {
        R0_IDLE		= 4'b0000, 
		R0_PRESSED  = 4'b0001, 
		R0_HOLD     = 4'b0010,
        R1_IDLE     = 4'b0011, 
		R1_PRESSED  = 4'b0100, 
		R1_HOLD     = 4'b0101,
        R2_IDLE     = 4'b0110, 
		R2_PRESSED  = 4'b0111, 
		R2_HOLD     = 4'b1000,
        R3_IDLE     = 4'b1001, 
		R3_PRESSED  = 4'b1010, 
		R3_HOLD     = 4'b1011
    } statetype;

    statetype state, nextstate;

    logic        button_pressed;
    logic        exact1_button;              // strobe
    //logic [3:0]  row_pressed_int;      // one-hot row identifier

    always_ff @(posedge clk or negedge reset) begin
        if (~reset) begin
            state           <= R0_IDLE;
            button_pressed  <= 1'b0;
            exact1_button   <= 1'b0;
        end else begin
            state           <= nextstate;
            button_pressed  <= |col;   // any column high?
            exact1_button   <= ($countones(~col) == 1);   // exactly one column high?
        end
    end

     always_comb begin
        case (state)
            R0_IDLE:    nextstate = exact1_button ? R0_PRESSED : R1_IDLE;
            R0_PRESSED: nextstate = exact1_button ? R0_HOLD    : R1_IDLE;
            R0_HOLD:    nextstate = button_pressed  ? R0_HOLD    : R1_IDLE;

            R1_IDLE:    nextstate = exact1_button ? R1_PRESSED : R2_IDLE;
            R1_PRESSED: nextstate = exact1_button ? R1_HOLD    : R2_IDLE;
            R1_HOLD:    nextstate = button_pressed  ? R1_HOLD    : R2_IDLE;

            R2_IDLE:    nextstate = exact1_button ? R2_PRESSED : R3_IDLE;
            R2_PRESSED: nextstate = exact1_button ? R2_HOLD    : R3_IDLE;
            R2_HOLD:    nextstate = button_pressed  ? R2_HOLD    : R3_IDLE;

            R3_IDLE:    nextstate = exact1_button ? R3_PRESSED : R0_IDLE;
            R3_PRESSED: nextstate = exact1_button ? R3_HOLD    : R0_IDLE;
            R3_HOLD:    nextstate = button_pressed  ? R3_HOLD    : R0_IDLE;

            default:    nextstate = R0_IDLE;
        endcase
	
end
	
    always_comb begin
        row = 4'b1111;
        case (state)
            R0_IDLE, R0_PRESSED, R0_HOLD: row = 4'b1110;
            R1_IDLE, R1_PRESSED, R1_HOLD: row = 4'b1101;
            R2_IDLE, R2_PRESSED, R2_HOLD: row = 4'b1011;
            R3_IDLE, R3_PRESSED, R3_HOLD: row = 4'b0111;
        endcase
    end

    always_comb begin
        case (state)
            R0_IDLE, R0_PRESSED, R0_HOLD: row_pressed = 4'b0001;
            R1_IDLE, R1_PRESSED, R1_HOLD: row_pressed = 4'b0010;
            R2_IDLE, R2_PRESSED, R2_HOLD: row_pressed = 4'b0100;
            R3_IDLE, R3_PRESSED, R3_HOLD: row_pressed = 4'b1000;
            default:                      row_pressed = 4'b0000;
        endcase
    end
	assign new_num = (state == R0_PRESSED | state == R1_PRESSED | state == R2_PRESSED | state == R3_PRESSED);
   
endmodule

