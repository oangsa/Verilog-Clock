module sevenseg_display_driver ( input clk, input reset, input tick_scan, input tick_1s, input [3:0] d0, input [3:0] d1, input [3:0] d2, input [3:0] d3, input alarm_mode, input [1:0] cursor_pos, input [3:0] alarm_d0, input [3:0] alarm_d1, input [3:0] alarm_d2, input [3:0] alarm_d3, input show_pwd, input show_ok, input show_err, input show_tmo, output [6:0] seg, output [3:0] an, output dp );
    // Character codes for decoder
    localparam CHAR_P = 5'd16;
    localparam CHAR_U = 5'd17;
    localparam CHAR_r = 5'd18;
    localparam CHAR_t = 5'd19;
    localparam CHAR_M = 5'd20;
    localparam CHAR_O = 5'd21;
    localparam CHAR_H = 5'd22;
    localparam CHAR_BLANK = 5'd23;
    localparam CHAR_d = 5'hd;
    localparam CHAR_E = 5'he;

    reg [3:0] selected_d0, selected_d1, selected_d2, selected_d3;
    reg cursor_blink;
    reg use_text_mode;
    reg [1:0] digit_sel;
    reg [4:0] current_digit;
    reg [3:0] an_reg;
    reg blink_state;

    // Blink counter for cursor indication
    always @(posedge clk or posedge reset) begin
        if (reset)
            blink_state <= 1'b0;
        else if (tick_1s)
            blink_state <= ~blink_state;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            digit_sel <= 2'd0;
        else if (tick_scan)
            digit_sel <= digit_sel + 1'b1;
    end

    always @* begin
        use_text_mode = show_pwd || show_ok || show_err || show_tmo;
        cursor_blink = 1'b0;
        current_digit = CHAR_BLANK;
        an_reg = 4'b1111;

        // Select time or alarm digits
        if (alarm_mode && !use_text_mode) begin
            selected_d0 = alarm_d0;
            selected_d1 = alarm_d1;
            selected_d2 = alarm_d2;
            selected_d3 = alarm_d3;
        end else begin
            selected_d0 = d0;
            selected_d1 = d1;
            selected_d2 = d2;
            selected_d3 = d3;
        end

        // Handle text display modes using decoder character codes
        if (show_pwd) begin
            // Display "Pd " - P d (Password)
            case (digit_sel)
                2'd0: begin current_digit = CHAR_d; an_reg = 4'b1110; end
                2'd1: begin current_digit = CHAR_BLANK; an_reg = 4'b1111; end
                2'd2: begin current_digit = CHAR_P; an_reg = 4'b1011; end
                2'd3: begin current_digit = CHAR_BLANK; an_reg = 4'b1111; end
            endcase
        end else if (show_ok) begin
            // Display "OK"
            case (digit_sel)
                2'd0: begin current_digit = CHAR_H; an_reg = 4'b1110; end  // K as H
                2'd1: begin current_digit = CHAR_O; an_reg = 4'b1101; end
                2'd2: begin current_digit = CHAR_BLANK; an_reg = 4'b1111; end
                2'd3: begin current_digit = CHAR_BLANK; an_reg = 4'b1111; end
            endcase
        end else if (show_err) begin
            // Display "Err"
            case (digit_sel)
                2'd0: begin current_digit = CHAR_r; an_reg = 4'b1110; end
                2'd1: begin current_digit = CHAR_r; an_reg = 4'b1101; end
                2'd2: begin current_digit = CHAR_E; an_reg = 4'b1011; end
                2'd3: begin current_digit = CHAR_BLANK; an_reg = 4'b1111; end
            endcase
        end else if (show_tmo) begin
            // Display "tMO" (timeout)
            case (digit_sel)
                2'd0: begin current_digit = CHAR_O; an_reg = 4'b1110; end
                2'd1: begin current_digit = CHAR_M; an_reg = 4'b1101; end
                2'd2: begin current_digit = CHAR_t; an_reg = 4'b1011; end
                2'd3: begin current_digit = CHAR_BLANK; an_reg = 4'b1111; end
            endcase
        end else begin
            // Normal digit display
            case (digit_sel)
                2'd0: begin
                    current_digit = {1'b0, selected_d0};
                    an_reg = 4'b1110;
                    cursor_blink = alarm_mode && (cursor_pos == 2'd0) && blink_state;
                end
                2'd1: begin
                    current_digit = {1'b0, selected_d1};
                    an_reg = 4'b1101;
                    cursor_blink = alarm_mode && (cursor_pos == 2'd1) && blink_state;
                end
                2'd2: begin
                    current_digit = {1'b0, selected_d2};
                    an_reg = 4'b1011;
                    cursor_blink = alarm_mode && (cursor_pos == 2'd2) && blink_state;
                end
                2'd3: begin
                    current_digit = {1'b0, selected_d3};
                    an_reg = 4'b0111;
                    cursor_blink = alarm_mode && (cursor_pos == 2'd3) && blink_state;
                end
            endcase

            // Hide digit when cursor is blinking
            if (cursor_blink)
                an_reg = 4'b1111;
        end
    end

    // Use single decoder for all display
    seven_segs_decoder u_dec (
        .digit (current_digit),
        .seg   (seg)
    );

    assign an = an_reg;
    assign dp = 1'b1;
endmodule
