module ct (
    input clk,
    input rst
);

    wire [5:0] opcode;
    wire [5:0] funct;
    wire reg_dst, alu_src, mem_to_reg, reg_write;
    wire mem_read, mem_write, branch;
    wire [1:0] alu_op;

    // wiring together control and datapath
    control ctrl (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op)
    );

    dp dp (
        .clk(clk),
        .rst(rst),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op),
        .opcode(opcode),
        .funct(funct)
    );

endmodule
