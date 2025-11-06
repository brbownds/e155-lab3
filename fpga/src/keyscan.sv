// Broderick Bownds
// brbownds@hmc.edu
// 10/16/2025
//
// Works with external "synchronizer.sv" that provides
//   row_pressed = row_sync (2-cycle delayed version of row)
//
// This FSM scans 4 rows, waits 2 clock cycles after each
// row change before checking columns, and coordinates with
// the debouncer and drive logic.
//

module keyscan (
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] col,             // keypad column inputs
    output logic [3:0] row, led,        // driven row + debug LEDs
    input  logic [3:0] row_pressed,     // synchronized (from synchronizer)
    input  logic       debounced,       // from debouncer
    output logic       debounce_en,     // enables debouncer
    output logic       drive_en         // enables drive state
);

    typedef enum logic [4:0] {
        R0_IDLE, R0_WAIT, R0_HOLD,
        R1_IDLE, R1_WAIT, R1_HOLD,
        R2_IDLE, R2_WAIT, R2_HOLD,
        R3_IDLE, R3_WAIT, R3_HOLD,
        DRIVE
    } statetype;

    statetype state, nextstate;

  
    logic [1:0] settle_cnt;         // 2-cycle delay counter
    logic       settle_done;        // becomes 1 after 2 cycles
    logic [3:0] button_pressed;     // any column active
    logic       exact1_button;      // exactly one col active
    logic       if_0, if_1, if_2, if_3;
	


    always_ff @(posedge clk, negedge reset) begin
        if (reset==0) begin
            state          <= R0_IDLE;
            button_pressed <= 0;
            exact1_button  <= 0;
            settle_cnt     <= 0;
        end
        else begin
            state          <= nextstate;
            exact1_button  <= ($onehot(col));
			
			if((state == R0_IDLE)||(state == R1_IDLE)||(state == R2_IDLE)||(state == R3_IDLE))
				button_pressed <= col;
			else
				button_pressed <= (^col);


            // settle counter increments in IDLE states
            if (((state == R0_IDLE)||(state == R1_IDLE)||(state == R2_IDLE)||(state == R3_IDLE)) && !settle_done)
                settle_cnt <= settle_cnt + 1;
            else
                settle_cnt <= 0;
        end
    end

    assign settle_done = (settle_cnt == 2);

  
    assign if_0 = row_pressed[0];
    assign if_1 = row_pressed[1];
    assign if_2 = row_pressed[2];
    assign if_3 = row_pressed[3];

    // Debug LEDs show active row
    assign led = row;

    always_comb begin
		
        nextstate = state;
         case (state)

            R0_IDLE:  nextstate = settle_done ? (exact1_button ? R0_WAIT : R1_IDLE) : R0_IDLE;
            R0_WAIT:  nextstate = debounced ? DRIVE : R0_WAIT;
            R0_HOLD:  nextstate = ((button_pressed & col) == 0) ? R1_IDLE : R0_HOLD;

            R1_IDLE:  nextstate = settle_done ? (exact1_button ? R1_WAIT : R2_IDLE) : R1_IDLE;
            R1_WAIT:  nextstate = debounced ? DRIVE : R1_WAIT;
            R1_HOLD:  nextstate = ((button_pressed & col) == 0) ? R2_IDLE : R1_HOLD;

            R2_IDLE:  nextstate = settle_done ? (exact1_button ? R2_WAIT : R3_IDLE) : R2_IDLE;
            R2_WAIT:  nextstate = debounced ? DRIVE : R2_WAIT;
            R2_HOLD:  nextstate = ((button_pressed & col) == 0) ? R3_IDLE : R2_HOLD;

            R3_IDLE:  nextstate = settle_done ? (exact1_button ? R3_WAIT : R0_IDLE) : R3_IDLE;
            R3_WAIT:  nextstate = debounced ? DRIVE : R3_WAIT;
            R3_HOLD:  nextstate = ((button_pressed & col) == 0) ? R0_IDLE : R3_HOLD;

            DRIVE: begin
                if (exact1_button) begin
                    if      (if_0) nextstate = R0_HOLD;
                    else if (if_1) nextstate = R1_HOLD;
                    else if (if_2) nextstate = R2_HOLD;
                    else if (if_3) nextstate = R3_HOLD;
                    else           nextstate = R0_IDLE;
                end
                else
                    nextstate = R0_IDLE;
            end

            default: nextstate = R0_IDLE;
        endcase
    end

   
    always_comb begin
         case (state)
            R0_IDLE, R0_WAIT, R0_HOLD: row = 4'b0001;
            R1_IDLE, R1_WAIT, R1_HOLD: row = 4'b0010;
            R2_IDLE, R2_WAIT, R2_HOLD: row = 4'b0100;
            R3_IDLE, R3_WAIT, R3_HOLD: row = 4'b1000;
            default: row = 4'b1111;
        endcase
    end

 
	assign debounce_en = ((state == R0_WAIT)||(state == R1_WAIT)||(state == R2_WAIT)||(state == R3_WAIT));
    assign drive_en    = (state == DRIVE);
	

endmodule


