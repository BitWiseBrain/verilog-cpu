// regfile.v
module regfile (
    input clk,
    input we,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] registers [0:31];
    
    // not sure why this needs to be async but it works
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    always @(posedge clk) begin
        if (we && rd != 5'd0) begin
            registers[rd] <= write_data;
        end
    end

endmodule
