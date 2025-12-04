// set password
module password_setter( input clk, input reset, input clear, input set_btn, input [15:0] sw, output reg [15:0] stored_pass, output reg has_pass );
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stored_pass <= 16'b0;
            has_pass    <= 1'b0;
        end else if (set_btn) begin
            stored_pass <= sw;
            has_pass    <= 1'b1;
        end else if (clear) begin
            stored_pass <= 16'b0;
            has_pass    <= 1'b0;
        end
    end
endmodule

// password checker
module password_checker( input [15:0] inserted_pass, input [15:0] stored_pass, input is_check, input has_pass, output match );
    assign match = is_check && (inserted_pass == stored_pass);
endmodule


// clear password
module password_clearer( input clk, input reset, input clear_btn, output reg clear_en );
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clear_en <= 1'b0;
        end else if (clear_btn) begin
            clear_en <= 1'b1;
        end else begin
            clear_en <= 1'b0;
        end
    end

endmodule
