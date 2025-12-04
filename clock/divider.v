module divider_1s (
    input  clk,
    input  reset,
    output reg tick
);
    reg [26:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == 27'd99_999_999) begin
                count <= 0;
                tick  <= 1;
            end else begin
                count <= count + 1;
                tick  <= 0;
            end
        end
    end
endmodule
