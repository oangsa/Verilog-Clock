module main( input clk, RsRx, input [15:0] sw, output [15:0] led, output [6:0] seg, output [3:0] an, output dp, input btnC, input btnU, input btnL, input btnR, input btnD );
    wire reset;
    wire btnU_pulse;
    wire btnD_pulse;
    wire btnL_pulse;
    wire btnR_pulse;
    wire btnC_pulse;

    wire tick_1s;
    wire tick_scan;

    wire [7:0] rx_data;
    wire rx_valid;

    // load time values from UART
    wire       load_time;
    wire [3:0] load_sec_ones, load_sec_tens;
    wire [3:0] load_min_ones, load_min_tens;
    wire [3:0] load_hr_ones,  load_hr_tens;

    // actual time
    wire [3:0] sec_ones, sec_tens;
    wire [3:0] min_ones, min_tens;
    wire [3:0] hr_ones,  hr_tens;

    // Alarm-related signals
    wire alarm_set_mode;
    wire mode_timeout;
    wire alarm_triggered;
    wire alarm_active;
    wire is_alarm_set;

    wire activity_pulse = (btnU_pulse || btnD_pulse || btnL_pulse || btnR_pulse || btnC_pulse) && alarm_set_mode;

    // TODO: INSTEAD OF ALWAYS ENABLED, MAKE ABLE TO TOGGLE ALARM ENABLED STATUS
    // IT'S ONLY ENABLED IF AND ONLY IF PASSWORD IS SET AND THE ALARM IS SET
    // DEFAULT ALARM WILL BE DISABLED
    wire alarm_enabled = has_pass && is_alarm_set;
    wire stop_alarm = btnU_pulse && alarm_active && !alarm_set_mode && match_alt;

    wire [4:0] alarm_hour;
    wire [5:0] alarm_min;
    wire [1:0] cursor_pos;
    wire [3:0] alarm_d3, alarm_d2, alarm_d1, alarm_d0;

    // Password functionality
    wire pwd_set_mode;
    wire save_password;
    wire [15:0] password_to_save;
    wire show_pwd, show_ok, show_err, show_tmo;

    wire setPassword = save_password;  // now comes from password mode controller
    wire checkPassword = btnU_pulse && has_pass && !alarm_set_mode && !pwd_set_mode;
    wire clearPassword = btnD_pulse && !alarm_set_mode && !alarm_active && !pwd_set_mode;

    wire [15:0] stored_pass;
    wire has_pass;
    wire match;
    wire match_alt;
    wire clear_en;

    wire led_set_ok;
    wire led_match_ok;
    wire led_match_fail;

    // Global Reset
    // To trigger this, hold btnC for 3 seconds
    reset_controller #(.HOLD_SECONDS(3)) u_reset_ctrl (
        .clk      (clk),
        .btnC     (btnC),
        .tick_1s  (tick_1s),
        .reset_out(reset)
    );

    // BTNS_DEBOUNCERS
    buttons_debouncer u_btns (
        .clk    (clk),
        .reset  (reset),
        .btnU   (btnU),
        .btnD   (btnD),
        .btnL   (btnL),
        .btnR   (btnR),
        .btnC   (btnC),
        .pulseU (btnU_pulse),
        .pulseD (btnD_pulse),
        .pulseL (btnL_pulse),
        .pulseR (btnR_pulse),
        .pulseC (btnC_pulse)
    );

    // Alarm mode controller
    alarm_mode_controller u_alarm_mode (
        .clk             (clk),
        .reset           (reset),
        .btnC_pulse      (btnC_pulse),
        .tick_1s         (tick_1s),
        .alarm_set_mode  (alarm_set_mode),
        .mode_timeout    (mode_timeout),
        .activity_pulse  (activity_pulse)
    );



    // Alarm setting module
    alarm_setter u_alarm_set (
        .clk         (clk),
        .reset       (reset),
        .set_mode    (alarm_set_mode),
        .is_alarm_set(is_alarm_set),
        .BTNU        (btnU_pulse),
        .BTND        (btnD_pulse),
        .BTNL        (btnL_pulse),
        .BTNR        (btnR_pulse),
        .BTNC        (btnC_pulse),
        .alarm_hour  (alarm_hour),
        .alarm_min   (alarm_min),
        .cursor_pos  (cursor_pos),
        .D3          (alarm_d3),
        .D2          (alarm_d2),
        .D1          (alarm_d1),
        .D0          (alarm_d0)
    );

    alarm_trigger u_alarm (
        .clk            (clk),
        .reset          (reset),
        .tick_1s        (tick_1s),
        .current_hr_tens (hr_tens),
        .current_hr_ones (hr_ones),
        .current_min_tens(min_tens),
        .current_min_ones(min_ones),
        .current_sec_tens(sec_tens),
        .current_sec_ones(sec_ones),
        .alarm_hr_tens  (alarm_d3),
        .alarm_hr_ones  (alarm_d2),
        .alarm_min_tens (alarm_d1),
        .alarm_min_ones (alarm_d0),
        .alarm_enabled  (alarm_enabled),
        .stop_alarm     (stop_alarm),
        .alarm_triggered(alarm_triggered),
        .alarm_active   (alarm_active)
    );

    divider_1s u_div1s (
        .clk   (clk),
        .reset (reset),
        .tick  (tick_1s)
    );

    divider_scan u_divscan (
        .clk   (clk),
        .reset (reset),
        .tick  (tick_scan)
    );

    uart_rx #(
        .CLK_FREQ (100_000_000),
        .BAUD     (115200)
    ) u_uart_rx (
        .clk        (clk),
        .reset      (reset),
        .rx         (RsRx),
        .data       (rx_data),
        .valid      (rx_valid)
    );

    time_loader u_tload (
        .clk(clk), .reset(reset),
        .rx_data(rx_data), .rx_valid(rx_valid),
        .load(load_time),
        .load_sec_ones(load_sec_ones),
        .load_sec_tens(load_sec_tens),
        .load_min_ones(load_min_ones),
        .load_min_tens(load_min_tens),
        .load_hr_ones(load_hr_ones),
        .load_hr_tens(load_hr_tens)
    );

    counter_24hr u_time (
        .clk_1s(clk),
        .reset(reset),
        .enable(tick_1s),
        .load(load_time),
        .load_sec_ones(load_sec_ones),
        .load_sec_tens(load_sec_tens),
        .load_min_ones(load_min_ones),
        .load_min_tens(load_min_tens),
        .load_hr_ones(load_hr_ones),
        .load_hr_tens(load_hr_tens),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens),
        .hr_ones(hr_ones),
        .hr_tens(hr_tens)
    );

    sevenseg_display_driver u_disp (
        .clk(clk),
        .reset(reset),
        .tick_scan(tick_scan),
        .tick_1s(tick_1s),
        .d0(min_ones),
        .d1(min_tens),
        .d2(hr_ones),
        .d3(hr_tens),
        .alarm_mode(alarm_set_mode),
        .cursor_pos(cursor_pos),
        .alarm_d0(alarm_d0),
        .alarm_d1(alarm_d1),
        .alarm_d2(alarm_d2),
        .alarm_d3(alarm_d3),
        // Password display signals
        .show_pwd(show_pwd),
        .show_ok(show_ok),
        .show_err(show_err),
        .show_tmo(show_tmo),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // Password mode controller - handles password setting with timeout
    password_mode_controller #( .TIMEOUT_SECONDS(10), .MESSAGE_DISPLAY_SECONDS(2) ) u_pwd_mode (
        .clk              (clk),
        .reset            (reset),
        .tick_1s          (tick_1s),
        .btnU_pulse       (btnU_pulse && !alarm_set_mode),
        .sw               (sw),
        .has_pass         (has_pass),
        .pwd_set_mode     (pwd_set_mode),
        .save_password    (save_password),
        .password_to_save (password_to_save),
        .show_pwd         (show_pwd),
        .show_ok          (show_ok),
        .show_err         (show_err),
        .show_tmo         (show_tmo)
    );

    password_led_status pwd_status(
        .clk        (clk),
        .reset      (reset),
        .tick_1s    (tick_1s),
        .set_event  (setPassword),
        .check_event(checkPassword),
        .check_ok   (match_alt),
        .led_set    (led_set_ok),
        .led_match  (led_match_ok),
        .led_fail   (led_match_fail)
    );

    // TEST PASSWORD LOGIC
    // BTNU = SET_PASSWORD
    // BTND = CLEAR_PASSWORD
    password_clearer u_clear (
        .clk      (clk),
        .reset    (reset),
        .clear_btn(clearPassword),
        .clear_en (clear_en)
    );

    // password will be set if and only if password has not been set and btnU has been pressed.
    password_setter u_set (
        .clk        (clk),
        .reset      (reset),
        .set_btn    (setPassword),
        .sw         (password_to_save),  // use password from mode controller
        .stored_pass(stored_pass),
        .has_pass   (has_pass),
        .clear      (clear_en)
    );

    // password will be check if and only if password is already setted and btnU has been pressed.
    // we use the same button because ....why not?
    password_checker u_check (
        .inserted_pass(sw),
        .stored_pass(stored_pass),
        .has_pass   (has_pass),
        .is_check   (checkPassword),
        .match      (match_alt)
    );

    // LED Status indicators
    // 15 => password is set
    // 14 => alarm is set
    // 13 => when alarm is enabled (14 & 15 must on)
    // 11 => alarm set mode
    // 10 => pwd set mode
    // 0 => pwd set ok
    // 1 => pwd match
    // 2 => pwd mismatch
    // 3 => alarm active

    assign led[15] = has_pass;
    assign led[14] = is_alarm_set;
    assign led[13] = alarm_enabled;

    // Mode indicators
    assign led[11] = pwd_set_mode;
    assign led[10] = alarm_set_mode;

    // Password status LEDs
    assign led[0]  = led_set_ok;
    assign led[1]  = led_match_ok;
    assign led[2]  = led_match_fail;

    // Alarm active LED
    assign led[3] = alarm_active;
endmodule
