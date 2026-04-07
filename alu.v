module alu (
    input [2:0] alu_control,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] result,
    output zero
);

    always @(*) begin
        case (alu_control)
            3'b010: result = a + b; // add
            3'b110: result = a - b; // sub
            3'b000: result = a & b; // and
            3'b001: result = a | b; // or
            3'b111: result = (a < b) ? 32'd1 : 32'd0; // slt
            default: result = 32'd0; // idk what default should be
        endcase
    end

    // zero flag for branch
    assign zero = (result == 32'd0);

endmodule
