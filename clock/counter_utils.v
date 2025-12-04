module counter_0to59 ( input  clk, reset, enable, load, input [3:0] load_d0, load_d1, output reg [3:0] d0, d1, output reg  pulse );
always @(posedge clk or posedge reset) begin
    if (reset) begin
        d0    <= 0;
        d1    <= 0;
        pulse <= 0;
    end
    else if (load) begin
        d0 <= load_d0;
        d1 <= load_d1;
        pulse <= 0;
    end
    else begin
        pulse <= 0;

        if (enable) begin
            if (d0 < 9) begin
                d0 <= d0 + 1;
            end else begin
                d0 <= 0;
                if (d1 < 5) begin
                    d1 <= d1 + 1;
                end else begin
                    d1    <= 0;
                    pulse <= 1;
                end
            end
        end
    end
end

endmodule

module counter_0to23( input  clk, reset, enable, load, input [3:0] load_d0, load_d1, output reg [3:0] d0, d1 );
always @(posedge clk or posedge reset) begin
   if (reset) begin
       d0 <= 0;
       d1 <= 0;
   end
   else if (load) begin
       d0 <= load_d0;
       d1 <= load_d1;
   end
   else if (enable) begin
       if (d1 == 2 && d0 == 3) begin
           d0 <= 0;
           d1 <= 0;
       end

       else if (d0 < 9) begin
           d0 <= d0 + 1;
       end

       else begin
           d0 <= 0;
           d1 <= d1 + 1;
       end
   end
end

endmodule
