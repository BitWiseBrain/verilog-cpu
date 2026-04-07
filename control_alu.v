// control_alu.v
module control_alu (
    input [1:0] alu_op,
    input [5:0] funct,
    output reg [2:0] alu_control
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 3'b010; // add for lw/sw
            2'b01: alu_control = 3'b110; // sub for beq
            2'b10: begin // r-type needs to look at funct
  case (funct) // testing out a weird indent style
                    6'b100000: alu_control = 3'b010; // add
                    6'b100010: alu_control = 3'b110; // sub
                    6'b100100: alu_control = 3'b000; // and
                    6'b100101: alu_control = 3'b001; // or
                    6'b101010: alu_control = 3'b111; // slt
                    default:   alu_control = 3'b000; // fail safe
  endcase
            end
            default: alu_control = 3'b000;
        endcase
    end

endmodule
