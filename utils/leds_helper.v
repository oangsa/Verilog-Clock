module led_hold #( parameter HOLD_SECONDS = 3 )( input clk, input reset, input tick_1s, input event_pulse, output reg led );
    reg [7:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            led     <= 1'b0;
            counter <= 8'd0;
        end else begin
            // start hold when event happens
            if (event_pulse) begin
                led     <= 1'b1;
                counter <= HOLD_SECONDS;
            end else if (tick_1s && counter != 0) begin
                counter <= counter - 1'b1;
                if (counter == 1)
                    led <= 1'b0;
            end
        end
    end
endmodule
