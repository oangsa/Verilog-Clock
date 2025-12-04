module password_mode_controller #( parameter TIMEOUT_SECONDS = 30, parameter MESSAGE_DISPLAY_SECONDS = 2)(
    input clk,
    input reset,
    input tick_1s,
    input btnU_pulse,          // enter mode / save password
    input [15:0] sw,           // switch values
    input has_pass,

    output reg pwd_set_mode,
    output reg save_password,
    output reg [15:0] password_to_save,

    // Display status outputs
    output reg show_pwd,       // show "PWD" on display
    output reg show_ok,        // show "OK" on display
    output reg show_err,       // show "ERR" on display
    output reg show_tmo        // show "TMO" on display
);

    reg [5:0] timeout_counter;
    reg [3:0] message_counter;

    // States
    localparam IDLE = 2'd0;
    localparam SETTING = 2'd1;
    localparam SHOW_MESSAGE = 2'd2;

    reg [1:0] state;
    reg [1:0] message_type; // 0=OK, 1=ERR, 2=TMO

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            pwd_set_mode <= 1'b0;
            save_password <= 1'b0;
            password_to_save <= 16'b0;
            timeout_counter <= 6'd0;
            message_counter <= 4'd0;
            show_pwd <= 1'b0;
            show_ok <= 1'b0;
            show_err <= 1'b0;
            show_tmo <= 1'b0;
            message_type <= 2'd0;

        end else begin
            save_password <= 1'b0;

            case (state)
                IDLE: begin
                    show_pwd <= 1'b0;
                    show_ok <= 1'b0;
                    show_err <= 1'b0;
                    show_tmo <= 1'b0;
                    pwd_set_mode <= 1'b0;

                    // Enter password setting mode when btnU pressed and no password yet
                    if (btnU_pulse && !has_pass) begin
                        state <= SETTING;
                        pwd_set_mode <= 1'b1;
                        show_pwd <= 1'b1;
                        timeout_counter <= TIMEOUT_SECONDS;
                    end
                end

                SETTING: begin
                    show_pwd <= 1'b1;
                    pwd_set_mode <= 1'b1;

                    // Timeout countdown
                    if (tick_1s) begin
                        if (timeout_counter > 0) begin
                            timeout_counter <= timeout_counter - 1'b1;

                        end else begin
                            // Timeout - exit mode and show TMO
                            state <= SHOW_MESSAGE;
                            message_type <= 2'd2; // TMO
                            message_counter <= MESSAGE_DISPLAY_SECONDS;
                            pwd_set_mode <= 1'b0;
                            show_pwd <= 1'b0;
                            show_tmo <= 1'b1;
                        end
                    end

                    // Reset timeout on button activity
                    if (btnU_pulse) begin
                        timeout_counter <= TIMEOUT_SECONDS;

                        // Try to save password
                        if (sw != 16'b0) begin
                            // Valid password
                            save_password <= 1'b1;
                            password_to_save <= sw;
                            state <= SHOW_MESSAGE;
                            message_type <= 2'd0; // OK
                            message_counter <= MESSAGE_DISPLAY_SECONDS;
                            pwd_set_mode <= 1'b0;
                            show_pwd <= 1'b0;
                            show_ok <= 1'b1;

                        end else begin
                            // No switches set - show error
                            state <= SHOW_MESSAGE;
                            message_type <= 2'd1; // ERR
                            message_counter <= MESSAGE_DISPLAY_SECONDS;
                            pwd_set_mode <= 1'b0;
                            show_pwd <= 1'b0;
                            show_err <= 1'b1;

                        end
                    end
                end

                SHOW_MESSAGE: begin
                    // Display message for N seconds
                    if (tick_1s) begin
                        if (message_counter > 0) begin
                            message_counter <= message_counter - 1'b1;

                        end else begin
                            // Message done, return to idle
                            state <= IDLE;
                            show_ok <= 1'b0;
                            show_err <= 1'b0;
                            show_tmo <= 1'b0;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
