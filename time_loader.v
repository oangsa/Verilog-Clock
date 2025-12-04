module time_loader ( input clk, reset, input [7:0] rx_data, input rx_valid, output reg load, output reg [3:0] load_hr_tens, output reg [3:0] load_hr_ones, output reg [3:0] load_min_tens, output reg [3:0] load_min_ones, output reg [3:0] load_sec_tens, output reg [3:0] load_sec_ones );
    reg [2:0] idx;

    function [3:0] to_bcd(input [7:0] ch);
        to_bcd = ch - "0";
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            idx  <= 0;
            load <= 0;
        end else begin
            load <= 0;
            if (rx_valid) begin
                if (rx_data == "\n") begin
                    if (idx == 3'd6)
                        load <= 1'b1;
                    idx <= 0;
                end else if (rx_data >= "0" && rx_data <= "9") begin
                    case (idx)
                        3'd0: load_hr_tens   <= to_bcd(rx_data);
                        3'd1: load_hr_ones   <= to_bcd(rx_data);
                        3'd2: load_min_tens  <= to_bcd(rx_data);
                        3'd3: load_min_ones  <= to_bcd(rx_data);
                        3'd4: load_sec_tens  <= to_bcd(rx_data);
                        3'd5: load_sec_ones  <= to_bcd(rx_data);
                    endcase
                    if (idx < 6)
                        idx <= idx + 1;
                end
            end
        end
    end
endmodule
