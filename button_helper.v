module button_one_pulse( input clk, input reset, input btn, output reg pulse );
    reg btn_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_d  <= 1'b0;
            pulse  <= 1'b0;
        end else begin
            // rising edge detect
            pulse <= btn & ~btn_d;
            btn_d <= btn;
        end
    end
endmodule

// Debouncer for all 5 buttons using button_one_pulse
module buttons_debouncer (
    input clk, input reset,
    input btnU, input btnD, input btnL, input btnR, input btnC,
    output pulseU, output pulseD, output pulseL, output pulseR, output pulseC
);

    button_one_pulse u_btnU (
        .clk   (clk),
        .reset (reset),
        .btn   (btnU),
        .pulse (pulseU)
    );

    button_one_pulse u_btnD (
        .clk   (clk),
        .reset (reset),
        .btn   (btnD),
        .pulse (pulseD)
    );

    button_one_pulse u_btnL (
        .clk   (clk),
        .reset (reset),
        .btn   (btnL),
        .pulse (pulseL)
    );

    button_one_pulse u_btnR (
        .clk   (clk),
        .reset (reset),
        .btn   (btnR),
        .pulse (pulseR)
    );

    button_one_pulse u_btnC (
        .clk   (clk),
        .reset (reset),
        .btn   (btnC),
        .pulse (pulseC)
    );

endmodule
