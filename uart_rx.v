module uart_rx #( parameter CLK_FREQ = 100_000_000, parameter BAUD = 115200 )( input  clk, input  reset, input  rx, output reg [7:0] data, output reg valid );
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    localparam [1:0]
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3;

    reg [1:0] state = IDLE;
    reg [15:0] clk_cnt = 0;
    reg [2:0] bit_idx = 0;
    reg [7:0] r_data = 0;
    reg rx_d1, rx_d2;

    // sync input
    always @(posedge clk) begin
        rx_d1 <= rx;
        rx_d2 <= rx_d1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            clk_cnt <= 0;
            bit_idx <= 0;
            r_data  <= 0;
            data    <= 0;
            valid   <= 0;
        end else begin
            valid <= 0;

            case (state)
            IDLE: begin
                if (rx_d2 == 1'b0) begin   // start bit
                    state   <= START;
                    clk_cnt <= 0;
                end
            end

            START: begin
                if (clk_cnt == (CLKS_PER_BIT/2)) begin
                    if (rx_d2 == 1'b0) begin
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        state   <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            DATA: begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    clk_cnt <= 0;
                    r_data[bit_idx] <= rx_d2;
                    if (bit_idx == 3'd7)
                        state <= STOP;
                    else
                        bit_idx <= bit_idx + 1;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            STOP: begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    state   <= IDLE;
                    data    <= r_data;
                    valid   <= 1'b1; // one-cycle pulse
                    clk_cnt <= 0;
                end else
                    clk_cnt <= clk_cnt + 1;
            end
            endcase
        end
    end

endmodule
