// Broderick Bownds
// brbownds@hmc.edu
// 9/20/25
// Debouncer: filters out switch bouncing by requiring the
// input enable to stay HIGH for a fixed duration before asserting debounced.

module debounce #(
    parameter integer CNT_MAX = 50_000_00  // adjust for your clk freq & debounce time
)(
    input  logic clk,
    input  logic reset,        // active-low reset
    input  logic debounce_en,  // raw input signal
    output logic debounced     // stable output
);

    logic [$clog2(CNT_MAX)-1:0] db_counter;

    always_ff @(posedge clk) begin
        if (reset==0) begin
            db_counter <= '0;
            debounced  <= 1'b0;
        end 
        else begin
            if (debounce_en) begin
                if (db_counter == CNT_MAX-1) begin
                    db_counter <= '0;
                    debounced  <= 1'b1;
                end 
                else begin
                    db_counter <= db_counter + 1;
                    debounced  <= 1'b0;
                end
            end 
            else begin
                db_counter <= 0;
                debounced  <= 1'b0;
            end
        end
    end

endmodule
