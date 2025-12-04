module reset_controller #( parameter HOLD_SECONDS = 3)( input clk, input btnC, input tick_1s, output reg reset_out );
    reg [7:0] hold_counter;
    reg btnC_d;

    always @(posedge clk) begin
        btnC_d <= btnC;

        if (btnC && btnC_d) begin
            if (tick_1s && hold_counter < HOLD_SECONDS) begin
                hold_counter <= hold_counter + 1;
            end

            // reset if hold for n secs
            if (hold_counter >= HOLD_SECONDS) begin
                reset_out <= 1'b1;
            end else begin
                reset_out <= 1'b0;
            end
        end else begin
            // Button released or not pressed
            hold_counter <= 8'd0;
            reset_out <= 1'b0;
        end
    end
endmodule
