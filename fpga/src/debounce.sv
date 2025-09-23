// Broderick Bownds
// brbownds@hmc.edu
// 9/20/25
// This module "debounce" takes into account for switching bouncing and countering that
// by holding a signal until it is receive a HIGH or 1 instead of bouncing from 0 to 1. 

module debounce #(
  parameter int CLK_FREQ_HZ      = 50_000_000,
  parameter int DEBOUNCE_TIME_MS = 20,
  parameter int REFRESH_HZ       = 1000, 
  parameter int DEBOUNCE_CYCLES  = (CLK_FREQ_HZ/1000)*DEBOUNCE_TIME_MS,
  parameter int TOGGLE_CYCLES    = CLK_FREQ_HZ/(2*REFRESH_HZ)
) (
  input  logic        clk,
  input  logic        reset,
  input  logic        en,           // press strobe
  input  logic [3:0]  digit,        // new digit from keyscan
  output logic [3:0]  digit_out,    // current digit to display
  output logic        disp0,
  output logic        disp1
);

  // debounce one-shot
  logic button_in;
  logic button_stable;
  logic button_pressed_pulse;
  logic [24:0] debounce_counter;
  logic [3:0] s0, s1;

  always_comb begin
    button_in = en;  // valid press only if digit is non-zero
  end

  always_ff @(posedge clk or negedge reset) begin
    if (~reset) begin
      button_stable        <= 1'b0;
      debounce_counter     <= 0;
      button_pressed_pulse <= 1'b0;
    end else begin
      button_pressed_pulse <= 1'b0;
      if (button_in != button_stable) begin
        if (debounce_counter >= DEBOUNCE_CYCLES - 1) begin
          button_stable        <= button_in;
          debounce_counter     <= 0;
          if (button_in)
            button_pressed_pulse <= 1'b1;
        end else begin
          debounce_counter <= debounce_counter + 1;
        end
      end else begin
        debounce_counter <= 0;
      end
    end
  end

  // display refresh counter + mux select
  logic        select_mux;
  logic [24:0] scan_counter;

  always_ff @(posedge clk or negedge reset) begin
    if (~reset) begin
      scan_counter <= 0;
      select_mux   <= 1'b0;
    end else begin
      if (scan_counter == TOGGLE_CYCLES - 1) begin
        scan_counter <= 0;
        select_mux   <= ~select_mux;
      end else begin
        scan_counter <= scan_counter + 1;
      end
    end
  end
  // in the debounce module we have the function of two-digit shift register
  // so that the new number gets updated from the right and shifts the old number
 always_ff @(posedge clk or negedge reset) begin
  if (~reset) begin
    s0 <= 0;
    s1 <= 0;
  end else if (button_pressed_pulse) begin
    s1 <= s0;
    s0 <= digit;
  end
end
  // output digit based on toggle
  always_comb begin
    digit_out = select_mux ? s1 : s0;
  end

  assign disp0 = ~select_mux;  // left digit
  assign disp1 =  select_mux;  // right digit

endmodule

