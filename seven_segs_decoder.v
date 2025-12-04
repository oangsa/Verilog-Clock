module seven_segs_decoder ( input [4:0] digit, output reg [6:0] seg );
    always @* begin
        case (digit)
            // Numbers 0-9
            5'd0:  seg = 7'b1000000; // 0
            5'd1:  seg = 7'b1111001; // 1
            5'd2:  seg = 7'b0100100; // 2
            5'd3:  seg = 7'b0110000; // 3
            5'd4:  seg = 7'b0011001; // 4
            5'd5:  seg = 7'b0010010; // 5
            5'd6:  seg = 7'b0000010; // 6
            5'd7:  seg = 7'b1111000; // 7
            5'd8:  seg = 7'b0000000; // 8
            5'd9:  seg = 7'b0010000; // 9

            // Letters (hex A-F)
            5'ha:  seg = 7'b0001000; // A
            5'hb:  seg = 7'b0000011; // b
            5'hc:  seg = 7'b1000110; // C
            5'hd:  seg = 7'b0100001; // d
            5'he:  seg = 7'b0000110; // E
            5'hf:  seg = 7'b0001110; // F

            // Extended letters for text display
            5'd16: seg = 7'b0001100; // P
            5'd17: seg = 7'b1000001; // U
            5'd18: seg = 7'b0101111; // r
            5'd19: seg = 7'b0000111; // t
            5'd20: seg = 7'b1001000; // M (approximation - n)
            5'd21: seg = 7'b1000000; // O (same as 0)
            5'd22: seg = 7'b0001001; // H (for K approximation)
            5'd23: seg = 7'b1111111; // blank

            default: seg = 7'b1111111; // blank
        endcase
    end
endmodule
