// instruction_memory.v
module instruction_memory (
    input [5:0] address,
    output [31:0] instruction
);

    reg [31:0] memory [0:63];

    initial begin
        $readmemh("imem.hex", memory); // gotta make sure this file exists before running
    end

    assign instruction = memory[address];

endmodule
