module counter_24hr ( input clk_1s, reset, enable, load, input [3:0] load_sec_ones, load_sec_tens, input [3:0] load_min_ones, load_min_tens, input [3:0] load_hr_ones,  load_hr_tens, output [3:0] sec_ones, sec_tens, output [3:0] min_ones, min_tens, output [3:0] hr_ones,  hr_tens );
    wire pulse_min;
    wire pulse_hour;

    counter_0to59 sec_counter (
        .clk     (clk_1s),
        .reset   (reset),
        .enable  (enable),
        .load    (load),
        .load_d0 (load_sec_ones),
        .load_d1 (load_sec_tens),
        .d0      (sec_ones),
        .d1      (sec_tens),
        .pulse   (pulse_min)
    );

    counter_0to59 min_counter (
        .clk     (clk_1s),
        .reset   (reset),
        .enable  (pulse_min),
        .load    (load),
        .load_d0 (load_min_ones),
        .load_d1 (load_min_tens),
        .d0      (min_ones),
        .d1      (min_tens),
        .pulse   (pulse_hour)
    );

    counter_0to23 hour_counter (
        .clk     (clk_1s),
        .reset   (reset),
        .enable  (pulse_hour),
        .load    (load),
        .load_d0 (load_hr_ones),
        .load_d1 (load_hr_tens),
        .d0      (hr_ones),
        .d1      (hr_tens)
    );

endmodule
