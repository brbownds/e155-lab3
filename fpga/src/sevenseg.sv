// Broderick Bownds
// brbownds@hmc.edu
// 9/1/2025

// This is the seven segment module is strictly combinational logic so we
// can use case statements. We can reutilize this from Lab 2 as our submodule
// for our top module for Lab 3 to select which 4-bit inputs go into this module.

module sevenseg (input  logic [3:0] s,
                 output logic [6:0] seg);
                     
    always_comb begin
        case (s)
            4'b0000: seg = 7'b1000000; // 0
            4'b0001: seg = 7'b1111001; // 1
            4'b0010: seg = 7'b0100100; // 2
            4'b0011: seg = 7'b0110000; // 3    
            4'b0100: seg = 7'b0011001; // 4        
            4'b0101: seg = 7'b0010010; // 5            
            4'b0110: seg = 7'b0000010; // 6            
            4'b0111: seg = 7'b1111000; // 7        
            4'b1000: seg = 7'b0000000; // 8        
            4'b1001: seg = 7'b0011000; // 9            
            4'b1010: seg = 7'b0001000; // A (10)        
            4'b1011: seg = 7'b0000011; // B (11)            
            4'b1100: seg = 7'b1000110; // C (12)        
            4'b1101: seg = 7'b0100001; // D (13)        
            4'b1110: seg = 7'b0000110; // E (14)    
            4'b1111: seg = 7'b0001110; // F (15)
            default: seg = 7'b1111111; // default case
        endcase
    end
endmodule