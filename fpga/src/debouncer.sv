// Broderick Bownds
// brbownds@hmc.edu
// 9/20/25

// Debouncer: filters out switch bouncing by requiring the
// input enable to stay HIGH for a fixed duration before asserting debounced.

module debouncer (
    input  logic clk,
    input  logic reset,        // active-low reset
    input  logic debounce_en,  // raw input signal
    output logic debounced     // stable output
);

    logic [24:0] db_counter;

    always_ff @(posedge clk, negedge reset) begin
        if (reset==0) begin
            db_counter <= 0;
            debounced  <= 1'b0;
        end 
        else begin
            if (debounce_en) begin
                if (db_counter == 6) begin
                    db_counter <= 0;
                    debounced  <= 1;
                end 
                else begin
                    db_counter <= db_counter + 1;
                    debounced  <= 0;
                end
            end 
            else begin
                db_counter <= 0;
                debounced  <= 0;
            end
        end
    end

endmodule