module alarm_mode_controller ( input clk, input reset, input btnC_pulse, input activity_pulse, input tick_1s, output reg alarm_set_mode, output reg mode_timeout );
    parameter TIMEOUT_SECONDS = 15;
    reg [5:0] timeout_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alarm_set_mode <= 1'b0;
            timeout_counter <= 6'd0;
            mode_timeout <= 1'b0;
        end else begin
            mode_timeout <= 1'b0;

            if (btnC_pulse && !alarm_set_mode) begin
                alarm_set_mode <= 1'b1;
                timeout_counter <= TIMEOUT_SECONDS;

            end else if (alarm_set_mode) begin
                if (btnC_pulse) begin
                    alarm_set_mode <= 1'b0;
                end

                else if (activity_pulse) begin
                    timeout_counter <= TIMEOUT_SECONDS;
                end

                else if (tick_1s) begin
                    if (timeout_counter > 0)
                    timeout_counter <= timeout_counter - 1;
                end

                if (timeout_counter == 0) begin
                    alarm_set_mode <= 1'b0;
                    mode_timeout   <= 1'b1;
                end
            end
        end
    end
endmodule
