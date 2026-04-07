// memory.v
module memory (
    input clk,
    input mem_read,
    input mem_write,
    input [5:0] address, // word addressed like the lab guide said
    input [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] memory [0:63];

    // textbook said async read
    assign read_data = mem_read ? memory[address] : 32'd0;

// synchronous write here
   always @(posedge clk) begin
       if (mem_write) begin
           memory[address] <= write_data;
       end
   end

endmodule
