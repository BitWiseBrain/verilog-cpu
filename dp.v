module dp (
    input clk,
    input rst,
    input reg_dst,
    input alu_src,
    input mem_to_reg,
    input reg_write,
    input mem_read,
    input mem_write,
    input branch,
    input [1:0] alu_op,
    output [5:0] opcode,
    output [5:0] funct
);

    reg [31:0] pc;
    wire [31:0] pc_next, pc_plus_4, branch_target;
    wire [31:0] instr;
    wire [31:0] write_data;
    wire [31:0] read_data1, read_data2;
    wire [31:0] sign_ext, alu_b;
    wire [31:0] alu_result, mem_read_data;
    wire [4:0] write_reg;
    wire [2:0] alu_ctrl;
    wire zero, do_branch;

    assign opcode = instr[31:26];
    assign funct = instr[5:0];

    // pc register logic
    always @(posedge clk or posedge rst) begin
        if (rst) pc <= 0;
        else     pc <= pc_next;
    end

    assign pc_plus_4 = pc + 4;
    assign sign_ext = {{16{instr[15]}}, instr[15:0]};
    assign branch_target = pc_plus_4 + (sign_ext << 2);
    
    assign do_branch = branch & zero;
    assign pc_next = do_branch ? branch_target : pc_plus_4;

    instruction_memory imem (
        .address(pc[7:2]), // word aligned for 64 blocks
        .instruction(instr)
    );

    assign write_reg = reg_dst ? instr[15:11] : instr[20:16];

    regfile rf (
        .clk(clk),
        .we(reg_write),
        .rs1(instr[25:21]),
        .rs2(instr[20:16]),
        .rd(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    assign alu_b = alu_src ? sign_ext : read_data2;

    control_alu ac (
        .alu_op(alu_op),
        .funct(funct),
        .alu_control(alu_ctrl)
    );

    alu the_alu (
        .alu_control(alu_ctrl),
        .a(read_data1),
        .b(alu_b),
        .result(alu_result),
        .zero(zero)
    );

    memory dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result[7:2]),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    assign write_data = mem_to_reg ? mem_read_data : alu_result;

endmodule
