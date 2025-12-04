module password_led_status(input clk, reset, tick_1s, set_event, check_event, check_ok, output led_set, led_match, led_fail);
    wire event_set_led = set_event;
    wire event_match_led = check_event & check_ok;
    wire event_fail_led = check_event & ~check_ok;

    led_hold #(.HOLD_SECONDS(1)) u_led_set (
        .clk        (clk),
        .reset      (reset),
        .tick_1s    (tick_1s),
        .event_pulse(event_set_led),
        .led        (led_set)
    );

    led_hold #(.HOLD_SECONDS(3)) u_led_match (
        .clk        (clk),
        .reset      (reset),
        .tick_1s    (tick_1s),
        .event_pulse(event_match_led),
        .led        (led_match)
    );

    led_hold #(.HOLD_SECONDS(3)) u_led_fail (
        .clk        (clk),
        .reset      (reset),
        .tick_1s    (tick_1s),
        .event_pulse(event_fail_led),
        .led        (led_fail)
    );
endmodule
