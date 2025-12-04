module alarm_setter (
	input wire clk,
    input wire reset,
    input wire set_mode,

    input wire BTNU,	// increment
    input wire BTND,   // decrement
    input wire BTNL,   // move left
    input wire BTNR,   // move right
    input wire BTNC,   // confirm

    output reg is_alarm_set,
    output reg [4:0] alarm_hour,
    output reg [5:0] alarm_min,
    output reg [1:0] cursor_pos,
	output reg [3:0] D3, D2, D1, D0
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // we should remove this im the real implementation
            D3 <= 4'd0;   // default alarm = 07:00
            D2 <= 4'd7;
            D1 <= 4'd0;
            D0 <= 4'd0;
            cursor_pos <= 2'd3;
            alarm_hour <= 5'd7;
            alarm_min <= 6'd0;
            is_alarm_set <= 1'b0;
        end
        else if (set_mode) begin

            // Cursor movement
            if (BTNL && cursor_pos < 3)
            cursor_pos <= cursor_pos + 1;
            if (BTNR && cursor_pos > 0)
            cursor_pos <= cursor_pos - 1;

            // Increment / decrement
            if (BTNU) begin
                case (cursor_pos)
                    2'd3: begin
                        if (D3 == 4'd2)
                            D3 <= 4'd0;
                        else
                            D3 <= D3 + 1;
                        if (D3 == 4'd1 && D2 > 4'd3)
                            D2 <= 4'd0; // fix overflow for 24h format
                    end
                    2'd2: begin
                        if (D3 == 4'd2) begin
                            if (D2 == 4'd3)
                                D2 <= 4'd0;
                            else
                                D2 <= D2 + 1;
                        end else begin
                            if (D2 == 4'd9)
                                D2 <= 4'd0;
                            else
                                D2 <= D2 + 1;
                        end
                    end
                    2'd1: begin
                        if (D1 == 4'd5)
                            D1 <= 4'd0;
                        else
                            D1 <= D1 + 1;
                    end
                    2'd0: begin
                        if (D0 == 4'd9)
                            D0 <= 4'd0;
                        else
                            D0 <= D0 + 1;
                    end
                endcase
            end
            if (BTND) begin
                case (cursor_pos)
                    2'd3: begin
                        if (D3 == 0)
                            D3 <= 4'd2;
                        else
                            D3 <= D3 - 1;
                        if (D3 == 4'd2 && D2 > 4'd3)
                            D2 <= 4'd3; // adjust
                    end
                    2'd2: begin
                        if (D3 == 4'd2)
                        begin
                            if (D2 == 0)
                                D2 <= 4'd3;
                            else
                                D2 <= D2 - 1;
                        end else begin
                            if (D2 == 0)
                                D2 <= 4'd9;
                            else
                                D2 <= D2 - 1;
                        end
                    end
                    2'd1: begin
                        if (D1 == 0)
                            D1 <= 4'd5;
                        else
                            D1 <= D1 - 1;
                    end
                    2'd0: begin
                        if (D0 == 0)
                            D0 <= 4'd9;
                        else
                            D0 <= D0 - 1;
                    end
                endcase
            end

            // Confirm = form hour/min
            if (BTNC) begin
                is_alarm_set <= 1'b1;
                alarm_hour <= D3*10 + D2;
                alarm_min  <= D1*10 + D0;
            end
        end
    end
endmodule


module alarm_trigger (
    input clk,
    input reset,
    input tick_1s,

    // CURRENT TIME
    input [3:0] current_hr_tens,
    input [3:0] current_hr_ones,
    input [3:0] current_min_tens,
    input [3:0] current_min_ones,
    input [3:0] current_sec_tens,
    input [3:0] current_sec_ones,

    // SET ALARM TIME
    input [3:0] alarm_hr_tens,
    input [3:0] alarm_hr_ones,
    input [3:0] alarm_min_tens,
    input [3:0] alarm_min_ones,

    input alarm_enabled,
    input stop_alarm,

    output reg alarm_triggered,
    output reg alarm_active
);

    wire time_match = (current_hr_tens  == alarm_hr_tens) && (current_hr_ones  == alarm_hr_ones) && (current_min_tens == alarm_min_tens) && (current_min_ones == alarm_min_ones);
    reg time_match_d;
    wire alarm_time_reached = time_match & ~time_match_d & alarm_enabled;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alarm_triggered <= 1'b0;
            alarm_active    <= 1'b0;
            time_match_d    <= 1'b0;
        end else begin
            time_match_d     <= time_match;
            alarm_triggered  <= 1'b0;
            if (alarm_time_reached && !alarm_active) begin
                alarm_triggered <= 1'b1;
                alarm_active    <= 1'b1;
            end
            if (stop_alarm && alarm_active) begin
                alarm_active <= 1'b0;
            end
        end
    end
endmodule
